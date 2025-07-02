import 'package:injectable/injectable.dart';

import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class WatchTimelineItemsUseCase {
  final TimelineItemsRepository _repository;

  WatchTimelineItemsUseCase(this._repository);

  Stream<TimelineItem> call() {
    return _repository.watchTimelineItems();
  }
}
