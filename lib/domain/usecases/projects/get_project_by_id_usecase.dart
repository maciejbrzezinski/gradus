import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/project.dart';
import '../../repositories/projects_repository.dart';

@injectable
class GetProjectByIdUseCase {
  final ProjectsRepository _repository;

  GetProjectByIdUseCase(this._repository);

  Future<Either<Failure, Project?>> call(String projectId) {
    return _repository.getProjectById(projectId);
  }
}
