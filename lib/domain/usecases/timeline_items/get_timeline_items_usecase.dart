import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';
import '../../../core/error/failure.dart';

@injectable
class GetTimelineItemsUseCase {
  final TimelineItemsRepository _repository;

  GetTimelineItemsUseCase(this._repository);

  Future<Either<Failure, List<TimelineItem>>> call(List<String> itemIds) {
    return _repository.getTimelineItems(itemIds);
  }
}
