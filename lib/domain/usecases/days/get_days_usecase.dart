import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/day.dart';
import '../../repositories/days_repository.dart';

@injectable
class GetDaysUseCase {
  final DaysRepository _repository;

  GetDaysUseCase(this._repository);

  Future<Either<Failure, List<Day>>> call({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get the first emission from the stream
    final days = await _repository.getDays(projectId: projectId, startDate: startDate, endDate: endDate);

    return days.fold((failure) => Left(failure), (daysList) {
      // Ensure the list is sorted by date
      daysList.sort((a, b) => a.date.compareTo(b.date));
      return Right(daysList);
    });
  }
}
