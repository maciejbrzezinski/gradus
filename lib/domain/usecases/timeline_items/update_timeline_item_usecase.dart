import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class UpdateTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  UpdateTimelineItemUseCase(this._repository);

  Future<Either<Failure, Unit>> call(TimelineItem item) {
    return _repository.updateTimelineItem(item);
  }
}
