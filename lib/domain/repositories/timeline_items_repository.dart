import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/timeline_item.dart';

abstract class TimelineItemsRepository {
  Stream<TimelineItem> watchTimelineItem(String itemId);

  Future<Either<Failure, TimelineItem>> getTimelineItem(String itemId);

  Future<Either<Failure, Unit>> createTimelineItem(TimelineItem item);

  Future<Either<Failure, Unit>> updateTimelineItem(TimelineItem item);

  Future<Either<Failure, Unit>> deleteTimelineItem(String itemId);

  // New methods for batch operations
  Future<Either<Failure, List<TimelineItem>>> getTimelineItems(List<String> itemIds);
  
  Stream<List<TimelineItem>> watchTimelineItems(List<String> itemIds);
}
