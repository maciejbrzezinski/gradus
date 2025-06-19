import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_datasource.dart';

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsDataSource _dataSource;

  ProjectsRepositoryImpl(this._dataSource);

  @override
  Stream<List<Project>> watchProjects() {
    try {
      return _dataSource.watchProjects().handleError((error) {
        return Left(Failure.unknownFailure(message: error.toString()));
      });
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final projects = await _dataSource.getProjects();
      return Right(projects);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project?>> getProjectById(String projectId) async {
    try {
      final project = await _dataSource.getProjectById(projectId);
      return Right(project);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createProject(Project project) async {
    try {
      await _dataSource.createProject(project);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      await _dataSource.updateProject(project);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String projectId) async {
    try {
      await _dataSource.deleteProject(projectId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
