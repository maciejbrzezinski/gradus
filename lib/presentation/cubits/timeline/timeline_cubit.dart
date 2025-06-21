import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/usecases/days/get_days_usecase.dart';
import '../../../domain/usecases/days/watch_days_usecase.dart';
import '../../../domain/usecases/days/move_item_between_days_usecase.dart';
import '../../../domain/usecases/days/add_item_to_day_usecase.dart';
import '../../../domain/usecases/projects/get_projects_usecase.dart';
import '../../../domain/usecases/projects/watch_projects_usecase.dart';
import '../../../domain/usecases/projects/get_project_by_id_usecase.dart';
import '../../../domain/usecases/timeline_items/create_timeline_item_usecase.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/note_type.dart';
import '../../../domain/entities/timeline_item.dart';
import 'timeline_state.dart';

@injectable
class TimelineCubit extends Cubit<TimelineState> {
  final GetDaysUseCase _getDaysUseCase;
  final WatchDaysUseCase _watchDaysUseCase;
  final MoveItemBetweenDaysUseCase _moveItemBetweenDaysUseCase;
  final AddItemToDayUseCase _addItemToDayUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;
  final CreateTimelineItemUseCase _createTimelineItemUseCase;

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
    this._getProjectsUseCase,
    this._watchProjectsUseCase,
    this._getProjectByIdUseCase,
    this._createTimelineItemUseCase,
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

    await projectResult.fold(
      (failure) async => emit(TimelineState.error(failure: failure)),
      (project) async {
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

        daysResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (days) {
            emit(
              TimelineState.loaded(
                days: days,
                selectedProject: _selectedProject,
                availableProjects: _availableProjects,
              ),
            );
            // Start watching for changes
            _watchDays();
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

    if (_selectedProject != null) {
      // Load new data first
      final daysResult = await _getDaysUseCase(
        projectId: _selectedProject!.id,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      daysResult.fold(
        (failure) => emit(TimelineState.error(failure: failure)),
        (days) {
          emit(
            TimelineState.loaded(
              days: days,
              selectedProject: _selectedProject,
              availableProjects: _availableProjects,
            ),
          );
          // Update watching with new date range
          _watchDays();
        },
      );
    }
  }

  Future<void> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    // required int toIndex,
  }) async {
    final result = await _moveItemBetweenDaysUseCase(itemId: itemId, fromDay: fromDay, toDay: toDay, toIndex: 0);

    result.fold(
      (failure) => emit(TimelineState.error(failure: failure)),
      (_) {}, // Days will be automatically updated through stream
    );
  }

  Future<void> createNote({
    required String content,
    required NoteType type,
    required Day day,
  }) async {
    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final noteId = 'note_${now.millisecondsSinceEpoch}';
    
    final note = Note(
      id: noteId,
      createdAt: now,
      updatedAt: now,
      content: content,
      type: type,
    );

    // First create the timeline item
    final timelineItem = TimelineItem.note(note);
    final createResult = await _createTimelineItemUseCase(timelineItem);
    
    await createResult.fold(
      (failure) async => emit(TimelineState.error(failure: failure)),
      (_) async {
        // Then add it to the day
        final addResult = await _addItemToDayUseCase(itemId: noteId, day: day);
        addResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (_) {}, // Days will be automatically updated through stream
        );
      },
    );
  }

  Future<void> createTask({
    required String title,
    required Day day,
  }) async {
    if (_selectedProject == null) {
      emit(const TimelineState.error(failure: Failure.validationFailure(message: 'No project selected')));
      return;
    }

    final now = DateTime.now();
    final taskId = 'task_${now.millisecondsSinceEpoch}';
    
    final task = Task(
      id: taskId,
      createdAt: now,
      updatedAt: now,
      title: title,
      isCompleted: false,
    );

    // First create the timeline item
    final timelineItem = TimelineItem.task(task);
    final createResult = await _createTimelineItemUseCase(timelineItem);
    
    await createResult.fold(
      (failure) async => emit(TimelineState.error(failure: failure)),
      (_) async {
        // Then add it to the day
        final addResult = await _addItemToDayUseCase(itemId: taskId, day: day);
        addResult.fold(
          (failure) => emit(TimelineState.error(failure: failure)),
          (_) {}, // Days will be automatically updated through stream
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
