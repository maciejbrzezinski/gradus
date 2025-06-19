import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/project.dart';
import '../../repositories/projects_repository.dart';

@injectable
class GetProjectsUseCase {
  final ProjectsRepository _repository;

  GetProjectsUseCase(this._repository);

  Future<Either<Failure, List<Project>>> call() async {
    return await _repository.getProjects();
  }
}
