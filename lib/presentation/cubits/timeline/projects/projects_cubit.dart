import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../domain/usecases/projects/get_projects_usecase.dart';
import '../../../../domain/usecases/projects/watch_projects_usecase.dart';
import '../../../../domain/usecases/projects/get_project_by_id_usecase.dart';
import 'projects_state.dart';

@injectable
class ProjectsCubit extends Cubit<ProjectsState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;
  final GetProjectByIdUseCase _getProjectByIdUseCase;

  StreamSubscription? _projectsSubscription;

  ProjectsCubit(
    this._getProjectsUseCase,
    this._watchProjectsUseCase,
    this._getProjectByIdUseCase,
  ) : super(const ProjectsState.initial()) {
    _initializeProjects();
  }

  void _initializeProjects() async {
    await loadProjects();
    _startWatching();
  }

  Future<void> loadProjects() async {
    emit(const ProjectsState.loading());

    try {
      final projectsResult = await _getProjectsUseCase();
      projectsResult.fold(
        (failure) => emit(ProjectsState.error(failure: failure)),
        (projects) {
          final selectedProject = projects.firstOrNull;
          emit(ProjectsState.loaded(
            selectedProject: selectedProject,
            availableProjects: projects,
          ));
        },
      );
    } catch (e) {
      emit(ProjectsState.error(
        failure: Failure.unknownFailure(message: e.toString()),
      ));
    }
  }

  void _startWatching() {
    _projectsSubscription?.cancel();
    _projectsSubscription = _watchProjectsUseCase().listen((projects) {
      final currentState = state;
      if (currentState is ProjectsLoaded) {
        emit(currentState.copyWith(availableProjects: projects));
      }
    });
  }

  Future<void> switchProject(String projectId) async {
    final currentState = state;
    if (currentState is! ProjectsLoaded) return;

    final project = currentState.availableProjects
        .cast<dynamic>()
        .firstWhere((p) => p.id == projectId, orElse: () => null);

    if (project != null) {
      emit(currentState.copyWith(selectedProject: project));
    } else {
      final projectResult = await _getProjectByIdUseCase(projectId);
      projectResult.fold(
        (failure) => emit(ProjectsState.error(failure: failure)),
        (project) {
          if (project != null) {
            emit(currentState.copyWith(selectedProject: project));
          } else {
            emit(const ProjectsState.error(
              failure: Failure.validationFailure(message: 'Project not found'),
            ));
          }
        },
      );
    }
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}
