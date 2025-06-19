import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class CreateTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  CreateTimelineItemUseCase(this._repository);

  Future<Either<Failure, Unit>> call(TimelineItem item) {
    return _repository.createTimelineItem(item);
  }
}
