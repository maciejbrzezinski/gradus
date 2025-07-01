import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/core/utils/date_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart' hide Task;

import '../../../core/error/failure.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/days/get_days_usecase.dart';
import '../../../domain/usecases/days/watch_days_usecase.dart';
import '../../../domain/usecases/days/add_item_to_day_usecase.dart';
import '../../../domain/usecases/days/remove_item_from_day_usecase.dart';
import '../../../domain/usecases/days/move_item_between_days_usecase.dart';
import '../../../domain/usecases/projects/get_projects_usecase.dart';
import '../../../domain/usecases/projects/watch_projects_usecase.dart';
import '../../../domain/usecases/projects/get_project_by_id_usecase.dart';
import '../../../domain/usecases/timeline_items/get_timeline_items_usecase.dart';
import '../../../domain/usecases/timeline_items/watch_timeline_items_usecase.dart';
import '../../../domain/usecases/timeline_items/create_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/complete_recurring_task_usecase.dart';
import 'timeline_state.dart';

@injectable
class TimelineCubit extends Cubit<TimelineState> {
  final GetDaysUseCase _getDaysUseCase;
  final WatchDaysUseCase _watchDaysUseCase;
  final AddItemToDayUseCase _addItemToDayUseCase;
  final RemoveItemFromDayUseCase _removeItemFromDayUseCase;
  final MoveItemBetweenDaysUseCase _moveItemBetweenDaysUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final GetTimelineItemsUseCase _getTimelineItemsUseCase;
  final WatchTimelineItemsUseCase _watchTimelineItemsUseCase;
  final CreateTimelineItemUseCase _createTimelineItemUseCase;
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;
  final CompleteRecurringTaskUseCase _completeRecurringTaskUseCase;

  StreamSubscription? _daysSubscription;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _itemsSubscription;

  DateTime _currentStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _currentEndDate = DateTime.now().add(const Duration(days: 7));

  TimelineCubit(
    this._getDaysUseCase,
    this._watchDaysUseCase,
    this._addItemToDayUseCase,
    this._removeItemFromDayUseCase,
    this._moveItemBetweenDaysUseCase,
    this._getProjectsUseCase,
    this._watchProjectsUseCase,
    this._getProjectByIdUseCase,
    this._getTimelineItemsUseCase,
    this._watchTimelineItemsUseCase,
    this._createTimelineItemUseCase,
    this._updateTimelineItemUseCase,
    this._deleteTimelineItemUseCase,
    this._completeRecurringTaskUseCase,
  ) : super(const TimelineState.initial()) {
    _initializeTimeline();
  }

  void _initializeTimeline() async {
    await loadInitialData();
    _startWatching();
  }

  Future<void> loadInitialData() async {
    emit(const TimelineState.loading());

    try {
      // Load projects first
      final projectsResult = await _getProjectsUseCase();
      await projectsResult.fold(
        (failure) async {
          emit(TimelineState.error(failure: failure));
          return;
        },
        (projects) async {
          final selectedProject = projects.firstOrNull;

          if (selectedProject != null) {
            // Load days for selected project
            final daysResult = await _loadDaysForProject(
              selectedProject.id,
              _currentStartDate,
              _currentEndDate,
            );

            await daysResult.fold(
              (failure) async => emit(TimelineState.error(failure: failure)),
              (days) async {
                // Extract item IDs and load items
                final itemIds = _extractItemIdsFromDays(days);
                final itemsResult = await _loadItemsForIds(itemIds);

                itemsResult.fold(
                  (failure) => emit(TimelineState.error(failure: failure)),
                  (items) => emit(
                    TimelineState.loaded(
                      selectedProject: selectedProject,
                      availableProjects: projects,
                      days: days,
                      items: items,
                      startDate: _currentStartDate,
                      endDate: _currentEndDate,
                    ),
                  ),
                );
              },
            );
          } else {
            emit(
              TimelineState.loaded(
                selectedProject: null,
                availableProjects: projects,
                days: [],
                items: [],
                startDate: _currentStartDate,
                endDate: _currentEndDate,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: e.toString())));
    }
  }

  void _startWatching() {
    _watchProjects();
    _watchDays();
    _watchItems();
  }

  void _watchProjects() {
    _projectsSubscription?.cancel();
    _projectsSubscription = _watchProjectsUseCase().listen((projects) {
      final currentState = state;
      if (currentState is TimelineLoaded) {
        emit(currentState.copyWith(availableProjects: projects));
      }
    });
  }

  void _watchDays() {
    _daysSubscription?.cancel();

    final currentState = state;
    if (currentState is TimelineLoaded && currentState.selectedProject != null) {
      _daysSubscription =
          _watchDaysUseCase(
            projectId: currentState.selectedProject!.id,
            startDate: _currentStartDate,
            endDate: _currentEndDate,
          ).listen((days) {
            final currentState = state;
            if (currentState is TimelineLoaded) {
              emit(currentState.copyWith(days: days));
              // Update items watching when days change
              _updateItemsWatching(days);
            }
          });
    }
  }

  void _watchItems() {
    final currentState = state;
    if (currentState is TimelineLoaded) {
      _updateItemsWatching(currentState.days);
    }
  }

  // Helper methods for reducing code duplication
  List<String> _extractItemIdsFromDays(List<Day> days) {
    final allItemIds = <String>{};
    for (final day in days) {
      allItemIds.addAll(day.itemIds);
    }
    return allItemIds.toList();
  }

  Future<Either<Failure, List<Day>>> _loadDaysForProject(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getDaysUseCase(
      projectId: projectId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Either<Failure, List<TimelineItem>>> _loadItemsForIds(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return Future.value(const Right([]));
    }
    return _getTimelineItemsUseCase(itemIds);
  }

  void _updateItemsWatching(List<Day> days) {
    _itemsSubscription?.cancel();

    final allItemIds = _extractItemIdsFromDays(days);

    if (allItemIds.isNotEmpty) {
      _itemsSubscription = _watchTimelineItemsUseCase(allItemIds).listen((items) {
        final currentState = state;
        if (currentState is TimelineLoaded) {
          if (items.length < allItemIds.length) {
            final updatedItems = currentState.items.map((item) {
              return item.id == items.first.id ? items.first : item;
            }).toList();
            emit(currentState.copyWith(items: updatedItems));
          } else {
            emit(currentState.copyWith(items: items));
          }
        }
      });
    }
  }

  Future<void> switchProject(String projectId) async {
    emit(const TimelineState.loading());

    final projectResult = await _getProjectByIdUseCase(projectId);

    await projectResult.fold(
      (failure) async => emit(TimelineState.error(failure: failure)),
      (project) async {
        if (project == null) {
          emit(const TimelineState.error(failure: Failure.validationFailure(message: 'Project not found')));
          return;
        }

        // Load days for new project
        final daysResult = await _loadDaysForProject(
          project.id,
          _currentStartDate,
          _currentEndDate,
        );

        await daysResult.fold(
          (failure) async => emit(TimelineState.error(failure: failure)),
          (days) async {
            // Extract item IDs and load items
            final itemIds = _extractItemIdsFromDays(days);
            final itemsResult = await _loadItemsForIds(itemIds);

            itemsResult.fold(
              (failure) => emit(TimelineState.error(failure: failure)),
              (items) {
                final currentState = state;
                if (currentState is TimelineLoaded) {
                  emit(currentState.copyWith(selectedProject: project, days: days, items: items));
                  // Start watching for changes
                  _watchDays();
                  _watchItems();
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> loadMoreDays({bool loadPrevious = false}) async {
    if (loadPrevious) {
      _currentStartDate = _currentStartDate.subtract(const Duration(days: 7));
    } else {
      _currentEndDate = _currentEndDate.add(const Duration(days: 7));
    }

    final currentState = state;
    if (currentState is TimelineLoaded && currentState.selectedProject != null) {
      // Load new data
      final daysResult = await _loadDaysForProject(
        currentState.selectedProject!.id,
        _currentStartDate,
        _currentEndDate,
      );

      await daysResult.fold(
        (failure) async => emit(TimelineState.error(failure: failure)),
        (days) async {
          // Extract item IDs and load items
          final itemIds = _extractItemIdsFromDays(days);
          final itemsResult = await _loadItemsForIds(itemIds);

          itemsResult.fold(
            (failure) => emit(TimelineState.error(failure: failure)),
            (items) {
              emit(currentState.copyWith(
                days: days,
                items: items,
                startDate: _currentStartDate,
                endDate: _currentEndDate,
              ));
              // Update watching with new date range
              _watchDays();
              _watchItems();
            },
          );
        },
      );
    }
  }

  Future<String?> createItem({
    required Day day,
    required TimelineItem timelineItem,
  }) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return null;

    final itemId = timelineItem.id;

    // 1. Update state immediately
    final updatedItems = [...currentState.items, timelineItem];
    final updatedDays = currentState.days.map((d) {
      if (d.date.isSameDay(day.date) && d.projectId == day.projectId) {
        return d.copyWith(itemIds: [...d.itemIds, itemId]);
      }
      return d;
    }).toList();

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // 2. Save in background (fire-and-forget)
    _saveInBackground(() async {
      await _createTimelineItemUseCase(timelineItem);
      await _addItemToDayUseCase(itemId: itemId, day: day);
    });

    return itemId;
  }

  Future<String?> createItemAfterCurrent({
    required String currentItemId,
    required Day day,
    required TimelineItem timelineItem,
  }) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return null;

    // Find the position of the current item
    final currentIndex = day.itemIds.indexOf(currentItemId);
    if (currentIndex == -1) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'Current item not found')));
      return null;
    }

    final insertIndex = currentIndex + 1;
    final itemId = timelineItem.id;

    // 1. Update state immediately
    final updatedItems = [...currentState.items, timelineItem];
    final updatedDays = currentState.days.map((d) {
      if (d.date.isSameDay(day.date) && d.projectId == day.projectId) {
        final newItemIds = [...d.itemIds];
        newItemIds.insert(insertIndex.clamp(0, newItemIds.length), itemId);
        return d.copyWith(itemIds: newItemIds);
      }
      return d;
    }).toList();

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // 2. Save in background (fire-and-forget)
    _saveInBackground(() async {
      await _createTimelineItemUseCase(timelineItem);
      await _addItemToDayUseCase(itemId: itemId, day: day, index: insertIndex);
    });

    return itemId;
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // 1. Update state immediately
    final updatedItems = currentState.items.map((i) {
      return i.id == item.id ? item : i;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    // 2. Save in background (fire-and-forget)
    _saveInBackground(() => _updateTimelineItemUseCase(item));
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Check if it's the same day
    final isSameDay = fromDay.date.isAtSameMomentAs(toDay.date) && fromDay.projectId == toDay.projectId;

    // 1. Update state immediately
    final updatedDays = currentState.days.map((day) {
      if (isSameDay) {
        if (day.date.isAtSameMomentAs(fromDay.date) && day.projectId == fromDay.projectId) {
          // Handle same-day reordering
          final currentIndex = day.itemIds.indexOf(itemId);
          if (currentIndex == -1) return day;

          final updatedItemIds = [...day.itemIds];
          updatedItemIds.removeAt(currentIndex);

          final adjustedIndex = toIndex > currentIndex ? toIndex - 1 : toIndex;
          final finalIndex = adjustedIndex.clamp(0, updatedItemIds.length);
          updatedItemIds.insert(finalIndex, itemId);

          return day.copyWith(itemIds: updatedItemIds);
        }
      } else {
        if (day.date.isAtSameMomentAs(fromDay.date) && day.projectId == fromDay.projectId) {
          // Remove from source day
          return day.copyWith(itemIds: day.itemIds.where((id) => id != itemId).toList());
        } else if (day.date.isAtSameMomentAs(toDay.date) && day.projectId == toDay.projectId) {
          // Add to target day
          final updatedItemIds = [...day.itemIds];
          updatedItemIds.insert(toIndex.clamp(0, updatedItemIds.length), itemId);
          return day.copyWith(itemIds: updatedItemIds);
        }
      }
      return day;
    }).toList();

    emit(currentState.copyWith(days: updatedDays));

    // 2. Save in background (fire-and-forget)
    _saveInBackground(
      () => _moveItemBetweenDaysUseCase(itemId: itemId, fromDay: fromDay, toDay: toDay, toIndex: toIndex),
    );
  }

  Future<void> deleteItemFromDay({required String itemId, required Day day}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // 1. Update state immediately
    final updatedItems = currentState.items.where((item) => item.id != itemId).toList();
    final updatedDays = currentState.days.map((d) {
      if (d.date.isAtSameMomentAs(day.date) && d.projectId == day.projectId) {
        return d.copyWith(itemIds: d.itemIds.where((id) => id != itemId).toList());
      }
      return d;
    }).toList();

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // 2. Save in background (fire-and-forget)
    _saveInBackground(() async {
      await _removeItemFromDayUseCase(itemId: itemId, day: day);
      await _deleteTimelineItemUseCase(itemId);
    });
  }

  Future<void> completeRecurringTask({required Task task, required Day day, required bool isCompleted}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // 1. Update state immediately
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    final updatedItems = currentState.items.map((item) {
      if (item.id == task.id) {
        return TimelineItem.task(updatedTask);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    // 2. Use the CompleteRecurringTaskUseCase for the actual logic
    final result = await _completeRecurringTaskUseCase(task: task, currentDay: day, isCompleted: isCompleted);

    result.fold(
      (failure) {
        // Revert on failure
        final revertedItems = currentState.items.map((item) {
          if (item.id == task.id) {
            return TimelineItem.task(task);
          }
          return item;
        }).toList();
        emit(currentState.copyWith(items: revertedItems));
      },
      (_) {
        // Success - no need to do anything, the stream will update
      },
    );
  }


  void _saveInBackground(Future<void> Function() operation) {
    operation().catchError((error) {
      print('❌ [TimelineCubit] Background save failed: $error');
    });
  }

  @override
  Future<void> close() {
    _daysSubscription?.cancel();
    _projectsSubscription?.cancel();
    _itemsSubscription?.cancel();
    return super.close();
  }
}
