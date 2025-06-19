import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class DeleteTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  DeleteTimelineItemUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String itemId) {
    return _repository.deleteTimelineItem(itemId);
  }
}
