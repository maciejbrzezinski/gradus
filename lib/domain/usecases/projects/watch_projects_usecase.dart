import 'package:injectable/injectable.dart';

import '../../entities/project.dart';
import '../../repositories/projects_repository.dart';

@injectable
class WatchProjectsUseCase {
  final ProjectsRepository _repository;

  WatchProjectsUseCase(this._repository);

  Stream<List<Project>> call() {
    return _repository.watchProjects();
  }
}
