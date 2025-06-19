import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class GetTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  GetTimelineItemUseCase(this._repository);

  Future<Either<Failure, TimelineItem>> call(String itemId) async {
    return await _repository.getTimelineItem(itemId);
  }
}
