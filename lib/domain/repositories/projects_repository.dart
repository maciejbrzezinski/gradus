import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/project.dart';

abstract class ProjectsRepository {
  Stream<List<Project>> watchProjects();

  Future<Either<Failure, List<Project>>> getProjects();

  Future<Either<Failure, Project?>> getProjectById(String projectId);

  Future<Either<Failure, Unit>> createProject(Project project);

  Future<Either<Failure, Unit>> updateProject(Project project);

  Future<Either<Failure, Unit>> deleteProject(String projectId);
}
