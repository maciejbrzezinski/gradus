import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/day.dart';
import '../../domain/repositories/days_repository.dart';
import '../datasources/days_datasource.dart';

@LazySingleton(as: DaysRepository)
class DaysRepositoryImpl implements DaysRepository {
  final DaysDataSource _dataSource;

  DaysRepositoryImpl(this._dataSource);

  @override
  Stream<List<Day>> watchDays({required String projectId, required DateTime startDate, required DateTime endDate}) {
    try {
      return _dataSource.watchDays(projectId: projectId, startDate: startDate, endDate: endDate).handleError((error) {
        return Left(Failure.unknownFailure(message: error.toString()));
      });
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Future<Either<Failure, Day>> updateDay(Day day) async {
    try {
      final updatedDay = await _dataSource.updateDay(day);
      return Right(updatedDay);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> moveItemBetweenDays({
    required String itemId,
    required Day fromDay,
    required Day toDay,
    required int toIndex,
  }) async {
    try {
      await _dataSource.moveItemBetweenDays(itemId: itemId, fromDay: fromDay, toDay: toDay, toIndex: toIndex);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Day>>> getDays({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get the first emission from the stream
      final days = await _dataSource.getDays(projectId: projectId, startDate: startDate, endDate: endDate);
      return Right(days);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
