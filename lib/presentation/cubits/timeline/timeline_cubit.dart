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
import '../../../domain/entities/note.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/note_type.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import '../../../core/utils/text_commands.dart';
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
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;
  final AuthService _authService;

  StreamSubscription? _daysSubscription;
  StreamSubscription? _projectsSubscription;
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
    this._updateTimelineItemUseCase,
    this._deleteTimelineItemUseCase,
    this._authService,
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
            emit(
              TimelineState.loaded(
                days: days,
                selectedProject: _selectedProject,
                availableProjects: _availableProjects,
              ),
            );
          });
    }
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
    final result = await _moveItemBetweenDaysUseCase(itemId: itemId, fromDay: fromDay, toDay: toDay, toIndex: toIndex);

    result.fold(
      (failure) => emit(TimelineState.error(failure: failure)),
      (_) {}, // Days will be automatically updated through stream
    );
  }

  Future<void> createItemAfterCurrent({
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
      return;
    }

    final insertIndex = currentIndex + 1;
    print('🔍 [TimelineCubit] Will insert new item at index: $insertIndex');

    // Create the appropriate item type
    if (itemType == ItemType.task) {
      await _createTaskAtPosition(title: content ?? '', day: day, insertIndex: insertIndex);
    } else if (itemType.isHeadline || itemType == ItemType.textNote) {
      await _createNoteAtPosition(
        content: content ?? '',
        type: itemType.toNoteType(),
        day: day,
        insertIndex: insertIndex,
      );
    }
  }

  Future<void> _createTaskAtPosition({required String title, required Day day, required int insertIndex}) async {
    print('🔍 [TimelineCubit] _createTaskAtPosition called - title: "$title", insertIndex: $insertIndex');

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

    final task = Task(id: taskId, createdAt: now, updatedAt: now, title: title, isCompleted: false);

    // First create the timeline item
    final timelineItem = TimelineItem.task(task);
    final createResult = await _createTimelineItemUseCase(timelineItem);

    await createResult.fold(
      (failure) async {
        emit(TimelineState.error(failure: failure));
      },
      (_) async {
        // Then add it to the day at the specific position
        final addResult = await _addItemToDayUseCase(itemId: taskId, day: day, index: insertIndex);
        addResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (_) {}, // Days will be automatically updated through stream
        );
      },
    );
  }

  Future<void> _createNoteAtPosition({
    required String content,
    required NoteType type,
    required Day day,
    required int insertIndex,
  }) async {
    print(
      '🔍 [TimelineCubit] _createNoteAtPosition called - content: "$content", type: $type, insertIndex: $insertIndex',
    );

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

    final note = Note(id: noteId, createdAt: now, updatedAt: now, content: content, type: type);

    // First create the timeline item
    final timelineItem = TimelineItem.note(note);
    final createResult = await _createTimelineItemUseCase(timelineItem);

    await createResult.fold(
      (failure) async {
        emit(TimelineState.error(failure: failure));
      },
      (_) async {
        // Then add it to the day at the specific position
        final addResult = await _addItemToDayUseCase(itemId: noteId, day: day, index: insertIndex);
        addResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (_) {}, // Days will be automatically updated through stream
        );
      },
    );
  }

  Future<void> createNote({required String content, required NoteType type, required Day day}) async {
    print('🔍 [TimelineCubit] createNote called - content: "$content", type: $type, day: ${day.date}');
    print('🔍 [TimelineCubit] selectedProject: ${_selectedProject?.name ?? 'null'}');
    print('🔍 [TimelineCubit] isAuthenticated: ${_authService.isAuthenticated}');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
      print('✅ [TimelineCubit] User authenticated successfully');
    } catch (e) {
      print('❌ [TimelineCubit] Authentication failed: $e');
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return;
    }

    if (_selectedProject == null) {
      print('❌ [TimelineCubit] No project selected');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final noteId = 'note_${now.millisecondsSinceEpoch}';

    print('🔍 [TimelineCubit] Generated noteId: $noteId');

    final note = Note(id: noteId, createdAt: now, updatedAt: now, content: content, type: type);

    print('🔍 [TimelineCubit] Created note entity: ${note.toString()}');

    // First create the timeline item
    final timelineItem = TimelineItem.note(note);
    print('🔍 [TimelineCubit] Created timeline item, calling createTimelineItemUseCase...');

    final createResult = await _createTimelineItemUseCase(timelineItem);

    await createResult.fold(
      (failure) async {
        print('❌ [TimelineCubit] Failed to create timeline item: ${failure.toString()}');
        emit(TimelineState.error(failure: failure));
      },
      (_) async {
        print('✅ [TimelineCubit] Timeline item created successfully, adding to day...');
        // Then add it to the day
        final addResult = await _addItemToDayUseCase(itemId: noteId, day: day);
        addResult.fold(
          (failure) {
            print('❌ [TimelineCubit] Failed to add item to day: ${failure.toString()}');
            emit(TimelineState.error(failure: failure));
          },
          (_) {
            print('✅ [TimelineCubit] Item added to day successfully');
          }, // Days will be automatically updated through stream
        );
      },
    );
  }

  Future<void> createTask({required String title, required Day day}) async {
    print('🔍 [TimelineCubit] createTask called - title: "$title", day: ${day.date}');
    print('🔍 [TimelineCubit] selectedProject: ${_selectedProject?.name ?? 'null'}');
    print('🔍 [TimelineCubit] isAuthenticated: ${_authService.isAuthenticated}');

    // Ensure user is authenticated
    try {
      await _authService.ensureAuthenticated();
      print('✅ [TimelineCubit] User authenticated successfully');
    } catch (e) {
      print('❌ [TimelineCubit] Authentication failed: $e');
      emit(TimelineState.error(failure: Failure.unknownFailure(message: 'Authentication failed: $e')));
      return;
    }

    if (_selectedProject == null) {
      print('❌ [TimelineCubit] No project selected');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final taskId = 'task_${now.millisecondsSinceEpoch}';

    print('🔍 [TimelineCubit] Generated taskId: $taskId');

    final task = Task(id: taskId, createdAt: now, updatedAt: now, title: title, isCompleted: false);

    print('🔍 [TimelineCubit] Created task entity: ${task.toString()}');

    // First create the timeline item
    final timelineItem = TimelineItem.task(task);
    print('🔍 [TimelineCubit] Created timeline item, calling createTimelineItemUseCase...');

    final createResult = await _createTimelineItemUseCase(timelineItem);

    await createResult.fold(
      (failure) async {
        print('❌ [TimelineCubit] Failed to create timeline item: ${failure.toString()}');
        emit(TimelineState.error(failure: failure));
      },
      (_) async {
        print('✅ [TimelineCubit] Timeline item created successfully, adding to day...');
        // Then add it to the day
        final addResult = await _addItemToDayUseCase(itemId: taskId, day: day);
        addResult.fold(
          (failure) {
            print('❌ [TimelineCubit] Failed to add item to day: ${failure.toString()}');
            emit(TimelineState.error(failure: failure));
          },
          (_) {
            print('✅ [TimelineCubit] Item added to day successfully');
          }, // Days will be automatically updated through stream
        );
      },
    );
  }

  // Transformation methods for smart text input
  Future<void> transformNoteToTask({required String noteId, required String taskTitle}) async {
    print('🔍 [TimelineCubit] transformNoteToTask called - noteId: $noteId, title: "$taskTitle"');

    if (_selectedProject == null) {
      print('❌ [TimelineCubit] No project selected');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final task = Task(
      id: noteId,
      // Keep the same ID
      createdAt: now,
      updatedAt: now,
      title: taskTitle,
      isCompleted: false,
    );

    final timelineItem = TimelineItem.task(task);
    final result = await _updateTimelineItemUseCase(timelineItem);

    result.fold(
      (failure) {
        print('❌ [TimelineCubit] Failed to transform note to task: ${failure.toString()}');
        emit(TimelineState.error(failure: failure));
      },
      (_) {
        print('✅ [TimelineCubit] Note transformed to task successfully');
      }, // Items will be automatically updated through stream
    );
  }

  Future<void> transformTaskToNote({
    required String taskId,
    required String noteContent,
    required NoteType noteType,
  }) async {
    print('🔍 [TimelineCubit] transformTaskToNote called - taskId: $taskId, content: "$noteContent", type: $noteType');

    if (_selectedProject == null) {
      print('❌ [TimelineCubit] No project selected');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final note = Note(
      id: taskId,
      // Keep the same ID
      createdAt: now,
      updatedAt: now,
      content: noteContent,
      type: noteType,
    );

    final timelineItem = TimelineItem.note(note);
    final result = await _updateTimelineItemUseCase(timelineItem);

    result.fold(
      (failure) {
        print('❌ [TimelineCubit] Failed to transform task to note: ${failure.toString()}');
        emit(TimelineState.error(failure: failure));
      },
      (_) {
        print('✅ [TimelineCubit] Task transformed to note successfully');
      }, // Items will be automatically updated through stream
    );
  }

  Future<void> transformNoteType({required String noteId, required String content, required NoteType newType}) async {
    print('🔍 [TimelineCubit] transformNoteType called - noteId: $noteId, content: "$content", newType: $newType');

    if (_selectedProject == null) {
      print('❌ [TimelineCubit] No project selected');
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final note = Note(
      id: noteId,
      // Keep the same ID
      createdAt: now,
      updatedAt: now,
      content: content,
      type: newType,
    );

    final timelineItem = TimelineItem.note(note);
    final result = await _updateTimelineItemUseCase(timelineItem);

    result.fold(
      (failure) {
        print('❌ [TimelineCubit] Failed to transform note type: ${failure.toString()}');
        emit(TimelineState.error(failure: failure));
      },
      (_) {
        print('✅ [TimelineCubit] Note type transformed successfully');
      }, // Items will be automatically updated through stream
    );
  }

  Future<void> deleteItemFromDay({required String itemId, required Day day}) async {
    final removeResult = await _removeItemFromDayUseCase(itemId: itemId, day: day);
    await removeResult.fold(
      (failure) async => emit(TimelineState.error(failure: failure)),
      (_) async {
        final deleteResult = await _deleteTimelineItemUseCase(itemId);
        deleteResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (_) {},
        );
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
    return super.close();
  }
}
