import 'package:injectable/injectable.dart';

import '../../entities/day.dart';
import '../../repositories/days_repository.dart';

@injectable
class WatchDaysUseCase {
  final DaysRepository _repository;

  WatchDaysUseCase(this._repository);

  Stream<Day> call() {
    return _repository.watchDays();
  }
}
