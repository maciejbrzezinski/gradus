import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/repositories/timeline_items_repository.dart';
import '../datasources/timeline_items_datasource.dart';

@LazySingleton(as: TimelineItemsRepository)
class TimelineItemsRepositoryImpl implements TimelineItemsRepository {
  final TimelineItemsDataSource _dataSource;

  TimelineItemsRepositoryImpl(this._dataSource);

  @override
  Stream<TimelineItem> watchTimelineItem(String itemId) {
    try {
      return _dataSource.watchTimelineItem(itemId).handleError((error) {
        return Left(Failure.unknownFailure(message: error.toString()));
      });
    } catch (e) {
      return Stream.empty();
    }
  }

  @override
  Future<Either<Failure, TimelineItem>> getTimelineItem(String itemId) async {
    try {
      final item = await _dataSource.getTimelineItem(itemId);
      return Right(item);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createTimelineItem(TimelineItem item) async {
    try {
      await _dataSource.createTimelineItem(item);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTimelineItem(TimelineItem item) async {
    try {
      await _dataSource.updateTimelineItem(item);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTimelineItem(String itemId) async {
    try {
      await _dataSource.deleteTimelineItem(itemId);
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
