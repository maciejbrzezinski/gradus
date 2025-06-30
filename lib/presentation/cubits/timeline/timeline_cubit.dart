import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/services/auth_service.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/usecases/days/get_days_usecase.dart';
import '../../../domain/usecases/days/watch_days_usecase.dart';
import '../../../domain/usecases/days/move_item_between_days_usecase.dart';
import '../../../domain/usecases/days/add_item_to_day_usecase.dart';
import '../../../domain/usecases/days/remove_item_from_day_usecase.dart';
import '../../../domain/usecases/projects/get_projects_usecase.dart';
import '../../../domain/usecases/projects/watch_projects_usecase.dart';
import '../../../domain/usecases/projects/get_project_by_id_usecase.dart';
import '../../../domain/usecases/timeline_items/create_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/get_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/watch_timeline_item_usecase.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/note_type.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/complete_recurring_task_usecase.dart';
import '../../../core/utils/text_commands.dart';
import '../../../core/services/optimistic_sync_service.dart';
import 'timeline_state.dart';

@injectable
class TimelineCubit extends Cubit<TimelineState> {
  final GetDaysUseCase _getDaysUseCase;
  final WatchDaysUseCase _watchDaysUseCase;
  final MoveItemBetweenDaysUseCase _moveItemBetweenDaysUseCase;
  final AddItemToDayUseCase _addItemToDayUseCase;
  final RemoveItemFromDayUseCase _removeItemFromDayUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateTimelineItemUseCase _createTimelineItemUseCase;
  final GetTimelineItemUseCase _getTimelineItemUseCase;
  final WatchTimelineItemUseCase _watchTimelineItemUseCase;
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;
  final CompleteRecurringTaskUseCase _completeRecurringTaskUseCase;
  final AuthService _authService;
  final OptimisticSyncService _optimisticSyncService;

  StreamSubscription? _daysSubscription;
  StreamSubscription? _projectsSubscription;
  final Map<String, StreamSubscription> _itemSubscriptions = {};
  Project? _selectedProject;
  List<Project> _availableProjects = [];
  DateTime _currentStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _currentEndDate = DateTime.now().add(const Duration(days: 7));

  TimelineCubit(
    this._getDaysUseCase,
    this._watchDaysUseCase,
    this._moveItemBetweenDaysUseCase,
    this._addItemToDayUseCase,
    this._removeItemFromDayUseCase,
    this._getProjectsUseCase,
    this._watchProjectsUseCase,
    this._getProjectByIdUseCase,
    this._createTimelineItemUseCase,
    this._getTimelineItemUseCase,
    this._watchTimelineItemUseCase,
    this._updateTimelineItemUseCase,
    this._deleteTimelineItemUseCase,
    this._completeRecurringTaskUseCase,
    this._authService,
    this._optimisticSyncService,
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
          _availableProjects = projects;
          _selectedProject = projects.firstOrNull;

          // Load days for selected project
          if (_selectedProject != null) {
            final daysResult = await _getDaysUseCase(
              projectId: _selectedProject!.id,
              startDate: _currentStartDate,
              endDate: _currentEndDate,
            );

            daysResult.fold(
              (failure) => emit(TimelineState.error(failure: failure)),
              (days) => emit(
                TimelineState.loaded(
                  days: days,
                  selectedProject: _selectedProject,
                  availableProjects: _availableProjects,
                ),
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
  }

  void _watchProjects() {
    _projectsSubscription?.cancel();

    _projectsSubscription = _watchProjectsUseCase().listen((projects) {
      _availableProjects = projects;
      // Update state if we have days loaded
      final currentState = state;
      if (currentState is TimelineLoaded) {
        emit(currentState.copyWith(availableProjects: projects));
      }
    });
  }

  void _watchDays() {
    _daysSubscription?.cancel();

    if (_selectedProject != null) {
      _daysSubscription =
          _watchDaysUseCase(
            projectId: _selectedProject!.id,
            startDate: _currentStartDate,
            endDate: _currentEndDate,
          ).listen((days) {
            final currentState = state;
            if (currentState is TimelineLoaded) {
              // Update timeline item watching based on new days
              _updateTimelineItemWatching(days);
              
              emit(currentState.copyWith(
                days: days,
              ));
            } else {
              emit(
                TimelineState.loaded(
                  days: days,
                  selectedProject: _selectedProject,
                  availableProjects: _availableProjects,
                ),
              );
              // Start watching timeline items for initial load
              _updateTimelineItemWatching(days);
            }
          });
    }
  }

  void _updateTimelineItemWatching(List<Day> days) {
    // Get all item IDs from all days
    final allItemIds = <String>{};
    for (final day in days) {
      allItemIds.addAll(day.itemIds);
    }

    // Cancel subscriptions for items that are no longer visible
    final itemsToRemove = _itemSubscriptions.keys.where((itemId) => !allItemIds.contains(itemId)).toList();
    for (final itemId in itemsToRemove) {
      _itemSubscriptions[itemId]?.cancel();
      _itemSubscriptions.remove(itemId);
    }

    // Start watching new items
    for (final itemId in allItemIds) {
      if (!_itemSubscriptions.containsKey(itemId)) {
        _startWatchingTimelineItem(itemId);
      }
    }
  }

  void _startWatchingTimelineItem(String itemId) {
    _itemSubscriptions[itemId] = _watchTimelineItemUseCase(itemId).listen(
      (item) {
        _updateCachedItem(itemId, item);
      },
      onError: (error) {
        print('❌ [TimelineCubit] Error watching timeline item $itemId: $error');
        // Try to load the item once
        _loadTimelineItem(itemId);
      },
    );
  }

  Future<void> _loadTimelineItem(String itemId) async {
    final result = await _getTimelineItemUseCase(itemId);
    result.fold(
      (failure) {
        print('❌ [TimelineCubit] Failed to load timeline item $itemId: ${failure.toString()}');
      },
      (item) {
        _updateCachedItem(itemId, item);
      },
    );
  }

  void _updateCachedItem(String itemId, TimelineItem item) {
    final currentState = state;
    if (currentState is TimelineLoaded) {
      final updatedCachedItems = Map<String, TimelineItem>.from(currentState.cachedItems);
      updatedCachedItems[itemId] = item;
      
      emit(currentState.copyWith(cachedItems: updatedCachedItems));
    }
  }

  TimelineItem? getCachedItem(String itemId) {
    final currentState = state;
    if (currentState is TimelineLoaded) {
      return currentState.cachedItems[itemId];
    }
    return null;
  }

  Future<void> switchProject(String projectId) async {
    emit(const TimelineState.loading());

    final projectResult = await _getProjectByIdUseCase(projectId);

    await projectResult.fold((failure) async => emit(TimelineState.error(failure: failure)), (project) async {
      if (project == null) {
        emit(const TimelineState.error(failure: Failure.validationFailure(message: 'Project not found')));
        return;
      }

      _selectedProject = project;

      // Load initial data for new project
      final daysResult = await _getDaysUseCase(
        projectId: _selectedProject!.id,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      daysResult.fold((failure) => emit(TimelineState.error(failure: failure)), (days) {
        emit(
          TimelineState.loaded(days: days, selectedProject: _selectedProject, availableProjects: _availableProjects),
        );
        // Start watching for changes
        _watchDays();
      });
    });
  }

  Future<void> loadMoreDays({bool loadPrevious = false}) async {
    if (loadPrevious) {
      _currentStartDate = _currentStartDate.subtract(const Duration(days: 7));
    } else {
      _currentEndDate = _currentEndDate.add(const Duration(days: 7));
    }

    if (_selectedProject != null) {
      // Load new data first
      final daysResult = await _getDaysUseCase(
        projectId: _selectedProject!.id,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      daysResult.fold((failure) => emit(TimelineState.error(failure: failure)), (days) {
        emit(
          TimelineState.loaded(days: days, selectedProject: _selectedProject, availableProjects: _availableProjects),
        );
        // Update watching with new date range
        _watchDays();
      });
    }
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    print('🚀 [TimelineCubit] moveItemBetweenDays - OPTIMISTIC UPDATE');
    
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Generate operation ID
    final operationId = 'move_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Apply optimistic update immediately
    _applyOptimisticMove(
      itemId: itemId,
      fromDay: fromDay,
      toDay: toDay,
      toIndex: toIndex,
      operationId: operationId,
    );

    // Sync in background
    _optimisticSyncService.syncMoveOperation(
      itemId: itemId,
      fromDay: fromDay,
      toDay: toDay,
      toIndex: toIndex,
      operationId: operationId,
    ).catchError((error) {
      print('❌ [TimelineCubit] Move sync failed: $error');
      // TODO: Implement rollback mechanism
      _removeOptimisticOperation(operationId);
    });
  }

  void _applyOptimisticMove({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
    required String operationId,
  }) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Check if it's the same day (same date and projectId)
    final isSameDay = fromDay.date.isAtSameMomentAs(toDay.date) && 
                     fromDay.projectId == toDay.projectId;
    
    Map<String, Day> optimisticDays = Map.from(currentState.optimisticDays);
    
    if (isSameDay) {
      // Handle same-day reordering
      final currentIndex = fromDay.itemIds.indexOf(itemId);
      if (currentIndex == -1) return;
      
      final updatedItemIds = List<String>.from(fromDay.itemIds);
      updatedItemIds.removeAt(currentIndex);
      
      // Adjust target index if moving within same list
      final adjustedIndex = toIndex > currentIndex ? toIndex - 1 : toIndex;
      final finalIndex = adjustedIndex.clamp(0, updatedItemIds.length);
      updatedItemIds.insert(finalIndex, itemId);
      
      final updatedDay = fromDay.copyWith(itemIds: updatedItemIds);
      final dayKey = _getDayKey(updatedDay);
      optimisticDays[dayKey] = updatedDay;
    } else {
      // Handle cross-day moves
      // Remove from source day
      final updatedFromItemIds = List<String>.from(fromDay.itemIds)..remove(itemId);
      final updatedFromDay = fromDay.copyWith(itemIds: updatedFromItemIds);
      final fromDayKey = _getDayKey(updatedFromDay);
      optimisticDays[fromDayKey] = updatedFromDay;

      // Add to target day
      final updatedToItemIds = List<String>.from(toDay.itemIds);
      updatedToItemIds.insert(toIndex.clamp(0, updatedToItemIds.length), itemId);
      final updatedToDay = toDay.copyWith(itemIds: updatedToItemIds);
      final toDayKey = _getDayKey(updatedToDay);
      optimisticDays[toDayKey] = updatedToDay;
    }

    // Update state with optimistic changes
    emit(currentState.copyWith(
      pendingOperations: {...currentState.pendingOperations, operationId},
      optimisticDays: optimisticDays,
    ));
  }

  void _removeOptimisticOperation(String operationId) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final updatedPendingOperations = Set<String>.from(currentState.pendingOperations);
    updatedPendingOperations.remove(operationId);

    emit(currentState.copyWith(
      pendingOperations: updatedPendingOperations,
    ));
  }

  void _addPendingOperation(String operationId) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    emit(currentState.copyWith(
      pendingOperations: {...currentState.pendingOperations, operationId},
    ));
  }

  String _getDayKey(Day day) => '${day.projectId}_${day.date.toIso8601String().split('T')[0]}';

  void _applyOptimisticItemCreation({
    required String itemId,
    required Day day,
    required String operationId,
    int? insertIndex,
    TimelineItem? optimisticItem,
  }) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Add item to the specified position or end of the day's item list
    final updatedItemIds = List<String>.from(day.itemIds);
    if (insertIndex != null) {
      updatedItemIds.insert(insertIndex.clamp(0, updatedItemIds.length), itemId);
    } else {
      updatedItemIds.add(itemId);
    }
    
    final updatedDay = day.copyWith(itemIds: updatedItemIds);
    final dayKey = _getDayKey(updatedDay);

    Map<String, Day> optimisticDays = Map.from(currentState.optimisticDays);
    optimisticDays[dayKey] = updatedDay;

    // Add optimistic item to cache to prevent loading state
    Map<String, TimelineItem> updatedCachedItems = Map.from(currentState.cachedItems);
    if (optimisticItem != null) {
      updatedCachedItems[itemId] = optimisticItem;
    }

    // Update state with optimistic changes
    emit(currentState.copyWith(
      pendingOperations: {...currentState.pendingOperations, operationId},
      optimisticDays: optimisticDays,
      cachedItems: updatedCachedItems,
    ));
  }

  void _applyOptimisticItemDeletion({
    required String itemId,
    required Day day,
    required String operationId,
  }) {
    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Remove item from the day's item list
    final updatedItemIds = List<String>.from(day.itemIds)..remove(itemId);
    final updatedDay = day.copyWith(itemIds: updatedItemIds);
    final dayKey = _getDayKey(updatedDay);

    Map<String, Day> optimisticDays = Map.from(currentState.optimisticDays);
    optimisticDays[dayKey] = updatedDay;

    // Update state with optimistic changes
    emit(currentState.copyWith(
      pendingOperations: {...currentState.pendingOperations, operationId},
      optimisticDays: optimisticDays,
    ));
  }

  Future<String?> createItemAfterCurrent({
    required String currentItemId,
    required Day day,
    required ItemType itemType,
    String? content,
  }) async {
    print('🔍 [TimelineCubit] createItemAfterCurrent called - currentItemId: $currentItemId, itemType: $itemType');

    // Find the position of the current item
    final currentIndex = day.itemIds.indexOf(currentItemId);
    if (currentIndex == -1) {
      print('❌ [TimelineCubit] Current item not found in day');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'Current item not found')));
      return null;
    }

    final insertIndex = currentIndex + 1;
    print('🔍 [TimelineCubit] Will insert new item at index: $insertIndex');

    // Create the appropriate item type and return the new item ID
    if (itemType == ItemType.task) {
      return await _createTaskAtPosition(title: content ?? '', day: day, insertIndex: insertIndex);
    } else if (itemType.isHeadline || itemType == ItemType.textNote) {
      return await _createNoteAtPosition(
        content: content ?? '',
        type: itemType.toNoteType(),
        day: day,
        insertIndex: insertIndex,
      );
    }
    return null;
  }

  Future<String> _createTaskAtPosition({required String title, required Day day, required int insertIndex}) async {
    print('🚀 [TimelineCubit] _createTaskAtPosition - OPTIMISTIC UPDATE');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return '';
    }

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return '';
    }

    final now = DateTime.now();
    final taskId = 'task_${now.millisecondsSinceEpoch}';
    final operationId = 'create_task_at_position_${taskId}';

    final task = Task(id: taskId, createdAt: now, updatedAt: now, title: title, isCompleted: false);

    // Create timeline item for optimistic update
    final timelineItem = TimelineItem.task(task);

    // Apply optimistic update immediately
    _applyOptimisticItemCreation(
      itemId: taskId,
      day: day,
      operationId: operationId,
      insertIndex: insertIndex,
      optimisticItem: timelineItem,
    );

    // Sync in background
    _optimisticSyncService.syncTimelineItemCreation(timelineItem, operationId).then((_) {
      // After item is created, add it to the day at the specific position
      return _addItemToDayUseCase(itemId: taskId, day: day, index: insertIndex);
    }).then((addResult) {
      addResult.fold(
        (failure) {
          print('❌ [TimelineCubit] Failed to add task to day at position: ${failure.toString()}');
          _removeOptimisticOperation(operationId);
        },
        (_) {
          print('✅ [TimelineCubit] Task creation at position completed successfully');
          _removeOptimisticOperation(operationId);
        },
      );
    }).catchError((error) {
      print('❌ [TimelineCubit] Task creation at position sync failed: $error');
      _removeOptimisticOperation(operationId);
    });

    return taskId;
  }

  Future<String> _createNoteAtPosition({
    required String content,
    required NoteType type,
    required Day day,
    required int insertIndex,
  }) async {
    print('🚀 [TimelineCubit] _createNoteAtPosition - OPTIMISTIC UPDATE');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return '';
    }

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return '';
    }

    final now = DateTime.now();
    final noteId = 'note_${now.millisecondsSinceEpoch}';
    final operationId = 'create_note_at_position_${noteId}';

    final note = Note(id: noteId, createdAt: now, updatedAt: now, content: content, type: type);

    // Create timeline item for optimistic update
    final timelineItem = TimelineItem.note(note);

    // Apply optimistic update immediately
    _applyOptimisticItemCreation(
      itemId: noteId,
      day: day,
      operationId: operationId,
      insertIndex: insertIndex,
      optimisticItem: timelineItem,
    );

    // Sync in background
    _optimisticSyncService.syncTimelineItemCreation(timelineItem, operationId).then((_) {
      // After item is created, add it to the day at the specific position
      return _addItemToDayUseCase(itemId: noteId, day: day, index: insertIndex);
    }).then((addResult) {
      addResult.fold(
        (failure) {
          print('❌ [TimelineCubit] Failed to add note to day at position: ${failure.toString()}');
          _removeOptimisticOperation(operationId);
        },
        (_) {
          print('✅ [TimelineCubit] Note creation at position completed successfully');
          _removeOptimisticOperation(operationId);
        },
      );
    }).catchError((error) {
      print('❌ [TimelineCubit] Note creation at position sync failed: $error');
      _removeOptimisticOperation(operationId);
    });

    return noteId;
  }

  Future<void> createNote({required String content, required NoteType type, required Day day}) async {
    print('🚀 [TimelineCubit] createNote - OPTIMISTIC UPDATE');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return;
    }

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final noteId = 'note_${now.millisecondsSinceEpoch}';
    final operationId = 'create_note_${noteId}';

    final note = Note(id: noteId, createdAt: now, updatedAt: now, content: content, type: type);

    // Create timeline item for optimistic update
    final timelineItem = TimelineItem.note(note);

    // Apply optimistic update immediately
    _applyOptimisticItemCreation(
      itemId: noteId,
      day: day,
      operationId: operationId,
      optimisticItem: timelineItem,
    );

    // Sync in background
    _optimisticSyncService.syncTimelineItemCreation(timelineItem, operationId).then((_) {
      // After item is created, add it to the day
      return _addItemToDayUseCase(itemId: noteId, day: day);
    }).then((addResult) {
      addResult.fold(
        (failure) {
          print('❌ [TimelineCubit] Failed to add item to day: ${failure.toString()}');
          _removeOptimisticOperation(operationId);
        },
        (_) {
          print('✅ [TimelineCubit] Item creation completed successfully');
          _removeOptimisticOperation(operationId);
        },
      );
    }).catchError((error) {
      print('❌ [TimelineCubit] Item creation sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> createTask({required String title, required Day day}) async {
    print('🚀 [TimelineCubit] createTask - OPTIMISTIC UPDATE');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
    } catch (e) {
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return;
    }

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final taskId = 'task_${now.millisecondsSinceEpoch}';
    final operationId = 'create_task_${taskId}';

    final task = Task(id: taskId, createdAt: now, updatedAt: now, title: title, isCompleted: false);

    // Create timeline item for optimistic update
    final timelineItem = TimelineItem.task(task);

    // Apply optimistic update immediately
    _applyOptimisticItemCreation(
      itemId: taskId,
      day: day,
      operationId: operationId,
      optimisticItem: timelineItem,
    );

    // Sync in background
    _optimisticSyncService.syncTimelineItemCreation(timelineItem, operationId).then((_) {
      // After item is created, add it to the day
      return _addItemToDayUseCase(itemId: taskId, day: day);
    }).then((addResult) {
      addResult.fold(
        (failure) {
          print('❌ [TimelineCubit] Failed to add item to day: ${failure.toString()}');
          _removeOptimisticOperation(operationId);
        },
        (_) {
          print('✅ [TimelineCubit] Task creation completed successfully');
          _removeOptimisticOperation(operationId);
        },
      );
    }).catchError((error) {
      print('❌ [TimelineCubit] Task creation sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  // Transformation methods for smart text input
  Future<void> transformNoteToTask({required String noteId, required String taskTitle}) async {
    print('🚀 [TimelineCubit] transformNoteToTask - OPTIMISTIC UPDATE');

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final operationId = 'transform_note_to_task_${noteId}_${now.millisecondsSinceEpoch}';

    final task = Task(
      id: noteId,
      // Keep the same ID
      createdAt: now,
      updatedAt: now,
      title: taskTitle,
      isCompleted: false,
    );

    // Apply optimistic update immediately (transformations are handled by the stream)
    _addPendingOperation(operationId);

    // Sync in background
    final timelineItem = TimelineItem.task(task);
    _optimisticSyncService.syncTimelineItemUpdate(timelineItem, operationId).then((_) {
      print('✅ [TimelineCubit] Note to task transformation completed successfully');
      _removeOptimisticOperation(operationId);
    }).catchError((error) {
      print('❌ [TimelineCubit] Note to task transformation sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> transformTaskToNote({
    required String taskId,
    required String noteContent,
    required NoteType noteType,
  }) async {
    print('🚀 [TimelineCubit] transformTaskToNote - OPTIMISTIC UPDATE');

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final operationId = 'transform_task_to_note_${taskId}_${now.millisecondsSinceEpoch}';

    final note = Note(
      id: taskId,
      // Keep the same ID
      createdAt: now,
      updatedAt: now,
      content: noteContent,
      type: noteType,
    );

    // Apply optimistic update immediately (transformations are handled by the stream)
    _addPendingOperation(operationId);

    // Sync in background
    final timelineItem = TimelineItem.note(note);
    _optimisticSyncService.syncTimelineItemUpdate(timelineItem, operationId).then((_) {
      print('✅ [TimelineCubit] Task to note transformation completed successfully');
      _removeOptimisticOperation(operationId);
    }).catchError((error) {
      print('❌ [TimelineCubit] Task to note transformation sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> transformNoteType({required String noteId, required String content, required NoteType newType}) async {
    print('🚀 [TimelineCubit] transformNoteType - OPTIMISTIC UPDATE');

    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final operationId = 'transform_note_type_${noteId}_${now.millisecondsSinceEpoch}';

    final note = Note(
      id: noteId,
      createdAt: now,
      updatedAt: now,
      content: content,
      type: newType,
    );

    // Apply optimistic update immediately (transformations are handled by the stream)
    _addPendingOperation(operationId);

    // Sync in background
    final timelineItem = TimelineItem.note(note);
    _optimisticSyncService.syncTimelineItemUpdate(timelineItem, operationId).then((_) {
      print('✅ [TimelineCubit] Note type transformation completed successfully');
      _removeOptimisticOperation(operationId);
    }).catchError((error) {
      print('❌ [TimelineCubit] Note type transformation sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> deleteItemFromDay({required String itemId, required Day day}) async {
    print('🚀 [TimelineCubit] deleteItemFromDay - OPTIMISTIC UPDATE');

    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    // Generate operation ID
    final operationId = 'delete_${itemId}_${DateTime.now().millisecondsSinceEpoch}';

    // Apply optimistic update immediately
    _applyOptimisticItemDeletion(
      itemId: itemId,
      day: day,
      operationId: operationId,
    );

    // Sync in background
    _optimisticSyncService.syncItemDeletion(
      itemId: itemId,
      day: day,
      operationId: operationId,
    ).then((_) {
      print('✅ [TimelineCubit] Item deletion completed successfully');
      _removeOptimisticOperation(operationId);
    }).catchError((error) {
      print('❌ [TimelineCubit] Item deletion sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> updateTimelineItem(TimelineItem item) async {
    print('🚀 [TimelineCubit] updateTimelineItem - OPTIMISTIC UPDATE');

    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final operationId = 'update_item_${item.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Apply optimistic update to cached items
    final updatedCachedItems = Map<String, TimelineItem>.from(currentState.cachedItems);
    updatedCachedItems[item.id] = item;
    
    emit(currentState.copyWith(
      cachedItems: updatedCachedItems,
      pendingOperations: {...currentState.pendingOperations, operationId},
    ));

    // Sync in background
    _optimisticSyncService.syncTimelineItemUpdate(item, operationId).then((_) {
      print('✅ [TimelineCubit] Item update completed successfully');
      _removeOptimisticOperation(operationId);
    }).catchError((error) {
      print('❌ [TimelineCubit] Item update sync failed: $error');
      _removeOptimisticOperation(operationId);
    });
  }

  Future<void> completeRecurringTask({
    required Task task,
    required Day day,
    required bool isCompleted,
  }) async {
    print('🚀 [TimelineCubit] completeRecurringTask - task: ${task.title}, isCompleted: $isCompleted');

    final currentState = state;
    if (currentState is! TimelineLoaded) return;

    final operationId = 'complete_recurring_task_${task.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Apply optimistic update to cached items first
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    final updatedCachedItems = Map<String, TimelineItem>.from(currentState.cachedItems);
    updatedCachedItems[task.id] = TimelineItem.task(updatedTask);
    
    emit(currentState.copyWith(
      cachedItems: updatedCachedItems,
      pendingOperations: {...currentState.pendingOperations, operationId},
    ));

    // Use the CompleteRecurringTaskUseCase for the actual logic
    final result = await _completeRecurringTaskUseCase(
      task: task,
      currentDay: day,
      isCompleted: isCompleted,
    );

    result.fold(
      (failure) {
        print('❌ [TimelineCubit] Failed to complete recurring task: ${failure.toString()}');
        _removeOptimisticOperation(operationId);
        // Revert optimistic update on failure
        final revertedCachedItems = Map<String, TimelineItem>.from(currentState.cachedItems);
        revertedCachedItems[task.id] = TimelineItem.task(task);
        emit(currentState.copyWith(cachedItems: revertedCachedItems));
      },
      (_) {
        print('✅ [TimelineCubit] Recurring task completion completed successfully');
        _removeOptimisticOperation(operationId);
      },
    );
  }

  // Getters for easy access
  Project? get selectedProject => _selectedProject;

  DateTime get currentStartDate => _currentStartDate;

  DateTime get currentEndDate => _currentEndDate;

  @override
  Future<void> close() {
    _daysSubscription?.cancel();
    _projectsSubscription?.cancel();
    
    // Cancel all timeline item subscriptions
    for (final subscription in _itemSubscriptions.values) {
      subscription.cancel();
    }
    _itemSubscriptions.clear();
    
    return super.close();
  }
}
