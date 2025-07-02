import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/days/get_days_usecase.dart';
import '../../../domain/usecases/days/watch_days_usecase.dart';
import '../../../domain/usecases/days/add_item_to_day_usecase.dart';
import '../../../domain/usecases/days/remove_item_from_day_usecase.dart';
import '../../../domain/usecases/days/move_item_between_days_usecase.dart';
import '../../../domain/usecases/timeline_items/get_timeline_items_usecase.dart';
import '../../../domain/usecases/timeline_items/watch_timeline_items_usecase.dart';
import '../../../domain/usecases/timeline_items/create_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/complete_recurring_task_usecase.dart';
import 'timeline_state.dart';

@injectable
class TimelineCubit extends Cubit<TimelineState> {
  // Days use cases
  final GetDaysUseCase _getDaysUseCase;
  final WatchDaysUseCase _watchDaysUseCase;
  final AddItemToDayUseCase _addItemToDayUseCase;
  final RemoveItemFromDayUseCase _removeItemFromDayUseCase;
  final MoveItemBetweenDaysUseCase _moveItemBetweenDaysUseCase;

  // Timeline items use cases
  final GetTimelineItemsUseCase _getTimelineItemsUseCase;
  final WatchTimelineItemsUseCase _watchTimelineItemsUseCase;
  final CreateTimelineItemUseCase _createTimelineItemUseCase;
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;
  final CompleteRecurringTaskUseCase _completeRecurringTaskUseCase;

  StreamSubscription? _daysSubscription;
  StreamSubscription? _itemsSubscription;

  TimelineCubit(
    this._getDaysUseCase,
    this._watchDaysUseCase,
    this._addItemToDayUseCase,
    this._removeItemFromDayUseCase,
    this._moveItemBetweenDaysUseCase,
    this._getTimelineItemsUseCase,
    this._watchTimelineItemsUseCase,
    this._createTimelineItemUseCase,
    this._updateTimelineItemUseCase,
    this._deleteTimelineItemUseCase,
    this._completeRecurringTaskUseCase,
  ) : super(const TimelineState.initial());

  Future<void> loadTimelineForProject(String projectId, DateTime startDate, DateTime endDate) async {
    emit(const TimelineState.loading());

    try {
      final daysResult = await _getDaysUseCase(projectId: projectId, startDate: startDate, endDate: endDate);

      await daysResult.fold((failure) async => emit(TimelineState.error(failure: failure)), (days) async {
        // Load items for the days
        final allItemIds = <String>{};
        for (final day in days) {
          allItemIds.addAll(day.itemIds);
        }

        List<TimelineItem> items = [];
        if (allItemIds.isNotEmpty) {
          final itemsResult = await _getTimelineItemsUseCase(allItemIds.toList());
          itemsResult.fold(
            (failure) => emit(TimelineState.error(failure: failure)),
            (loadedItems) => items = loadedItems,
          );
        }

        emit(
          TimelineState.loaded(
            days: days,
            items: items,
            startDate: startDate,
            endDate: endDate,
            currentProjectId: projectId,
          ),
        );

        _startWatching(projectId, startDate, endDate, allItemIds.toList());
      });
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: e.toString())));
    }
  }

  void _startWatching(String projectId, DateTime startDate, DateTime endDate, List<String> itemIds) {
    _daysSubscription ??= _watchDaysUseCase().listen((day) {
      _updateDaysIntelligently(day);
    });

    _itemsSubscription ??= _watchTimelineItemsUseCase().listen((item) {
      _updateItemsIntelligently(item);
    });
  }

  Future<void> loadMoreDays({bool loadPrevious = false}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded || currentState.currentProjectId == null) return;

    DateTime newStartDate = currentState.startDate;
    DateTime newEndDate = currentState.endDate;

    if (loadPrevious) {
      newStartDate = currentState.startDate.subtract(const Duration(days: 7));
    } else {
      newEndDate = currentState.endDate.add(const Duration(days: 7));
    }

    try {
      final daysResult = await _getDaysUseCase(
        projectId: currentState.currentProjectId!,
        startDate: newStartDate,
        endDate: newEndDate,
      );

      await daysResult.fold((failure) async => emit(TimelineState.error(failure: failure)), (days) async {
        // Load items for the new days
        final allItemIds = <String>{};
        for (final day in days) {
          allItemIds.addAll(day.itemIds);
        }

        List<TimelineItem> items = [];
        if (allItemIds.isNotEmpty) {
          final itemsResult = await _getTimelineItemsUseCase(allItemIds.toList());
          itemsResult.fold(
            (failure) => emit(TimelineState.error(failure: failure)),
            (loadedItems) => items = loadedItems,
          );
        }

        emit(currentState.copyWith(days: days, items: items, startDate: newStartDate, endDate: newEndDate));

        _startWatching(currentState.currentProjectId!, newStartDate, newEndDate, allItemIds.toList());
      });
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: e.toString())));
    }
  }

  Future<String?> createItem({required Day day, required TimelineItem timelineItem}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return null;

    final itemId = timelineItem.id;

    // Optimistically update the state
    final updatedDays = currentState.days.map((d) {
      if (d.date.isSameDay(day.date) && d.projectId == day.projectId) {
        return d.copyWith(itemIds: [...d.itemIds, itemId]);
      }
      return d;
    }).toList();

    final updatedItems = [...currentState.items, timelineItem];

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // Save in background
    _saveInBackground(() async {
      await _createTimelineItemUseCase(timelineItem);
      await _addItemToDayUseCase(itemId: itemId, day: day);
    });

    return itemId;
  }

  String? createItemAfterCurrent({
    required String currentItemId,
    required Day day,
    required TimelineItem timelineItem,
  }) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return null;

    final currentIndex = day.itemIds.indexOf(currentItemId);
    if (currentIndex == -1) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'Current item not found')));
      return null;
    }

    final insertIndex = currentIndex + 1;
    final itemId = timelineItem.id;

    // Optimistically update the state
    final updatedDays = currentState.days.map((d) {
      if (d.date.isSameDay(day.date) && d.projectId == day.projectId) {
        final newItemIds = [...d.itemIds];
        newItemIds.insert(insertIndex.clamp(0, newItemIds.length), itemId);
        return d.copyWith(itemIds: newItemIds);
      }
      return d;
    }).toList();

    final updatedItems = [...currentState.items, timelineItem];

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // Save in background
    _saveInBackground(() async {
      await _createTimelineItemUseCase(timelineItem);
      await _addItemToDayUseCase(itemId: itemId, day: day, index: insertIndex);
    });

    return itemId;
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Optimistically update the state
    final updatedItems = currentState.items.map((i) {
      return i.id == item.id ? item : i;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    // Save in background
    _saveInBackground(() => _updateTimelineItemUseCase(item));
  }

  Future<void> deleteItemFromDay({required String itemId, required Day day}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Optimistically update the state
    final updatedDays = currentState.days.map((d) {
      if (d.date.isSameDay(day.date) && d.projectId == day.projectId) {
        return d.copyWith(itemIds: d.itemIds.where((id) => id != itemId).toList());
      }
      return d;
    }).toList();

    final updatedItems = currentState.items.where((item) => item.id != itemId).toList();

    emit(currentState.copyWith(days: updatedDays, items: updatedItems));

    // Save in background
    _saveInBackground(() async {
      await _removeItemFromDayUseCase(itemId: itemId, day: day);
      await _deleteTimelineItemUseCase(itemId);
    });
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final isSameDay = fromDay.date.isAtSameMomentAs(toDay.date) && fromDay.projectId == toDay.projectId;

    // Optimistically update the state
    final updatedDays = currentState.days.map((day) {
      if (isSameDay) {
        if (day.date.isAtSameMomentAs(fromDay.date) && day.projectId == fromDay.projectId) {
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
          return day.copyWith(itemIds: day.itemIds.where((id) => id != itemId).toList());
        } else if (day.date.isAtSameMomentAs(toDay.date) && day.projectId == toDay.projectId) {
          final updatedItemIds = [...day.itemIds];
          updatedItemIds.insert(toIndex.clamp(0, updatedItemIds.length), itemId);
          return day.copyWith(itemIds: updatedItemIds);
        }
      }
      return day;
    }).toList();

    emit(currentState.copyWith(days: updatedDays));

    // Save in background
    _saveInBackground(
      () => _moveItemBetweenDaysUseCase(itemId: itemId, fromDay: fromDay, toDay: toDay, toIndex: toIndex),
    );
  }

  Future<void> completeRecurringTask({required Task task, required Day day, required bool isCompleted}) async {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Optimistically update the state
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    final updatedItems = currentState.items.map((item) {
      if (item.id == task.id) {
        return TimelineItem.task(updatedTask);
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));

    // Handle recurring task completion
    final result = await _completeRecurringTaskUseCase(task: task, currentDay: day, isCompleted: isCompleted);

    result.fold((failure) {
      // Revert the optimistic update on failure
      final revertedItems = currentState.items.map((item) {
        if (item.id == task.id) {
          return TimelineItem.task(task);
        }
        return item;
      }).toList();
      emit(currentState.copyWith(items: revertedItems));
    }, (_) {});
  }

  void _updateDaysIntelligently(Day newDay) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final currentDays = List<Day>.from(currentState.days);
    bool hasChanges = false;

    final lookupNewDay = currentDays.indexWhere(
      (d) => d.date.isSameDay(newDay.date) && d.projectId == newDay.projectId,
    );
    if (lookupNewDay == -1) {
      // New day added
      currentDays.add(newDay);
      hasChanges = true;
    } else {
      // Existing day, check for updates based on updatedAt timestamp
      final currentDay = currentDays[lookupNewDay];
      if (newDay.updatedAt.isAfter(currentDay.updatedAt)) {
        currentDays[lookupNewDay] = newDay;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      emit(currentState.copyWith(days: currentDays));
    }
  }

  void _updateItemsIntelligently(TimelineItem item) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final currentItems = List<TimelineItem>.from(currentState.items);
    bool hasChanges = false;

    // Create a map of new items for efficient lookup
    final lookupItem = currentItems.indexWhere((i) => i.id == item.id);
    if (lookupItem == -1) {
      currentItems.add(item);
      hasChanges = true;
    } else {
      // Existing item, update it
      if (currentItems[lookupItem].updatedAt.isBefore(item.updatedAt)) {
        currentItems[lookupItem] = item;
        hasChanges = true;
      }
    }

    // Emit only if there were changes
    if (hasChanges) {
      emit(currentState.copyWith(items: currentItems));
    }
  }

  void _saveInBackground(Future<void> Function() operation) {
    operation().catchError((error) {
      print('❌ [TimelineCubit] Background save failed: $error');
    });
  }

  @override
  Future<void> close() {
    _daysSubscription?.cancel();
    _itemsSubscription?.cancel();
    return super.close();
  }
}
