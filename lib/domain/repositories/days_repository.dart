import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/day.dart';

abstract class DaysRepository {
  Stream<Day> watchDays();

  Future<Either<Failure, Day>> updateDay(Day day);

  Future<Either<Failure, List<Day>>> getDays({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, Unit>> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  });
}
