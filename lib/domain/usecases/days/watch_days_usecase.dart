import 'package:injectable/injectable.dart';

import '../../entities/day.dart';
import '../../repositories/days_repository.dart';

@injectable
class WatchDaysUseCase {
  final DaysRepository _repository;

  WatchDaysUseCase(this._repository);

  Stream<List<Day>> call({required String projectId, required DateTime startDate, required DateTime endDate}) {
    return _repository.watchDays(projectId: projectId, startDate: startDate, endDate: endDate);
  }
}
