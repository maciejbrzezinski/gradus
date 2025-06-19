import 'package:injectable/injectable.dart';

import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class WatchTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  WatchTimelineItemUseCase(this._repository);

  Stream<TimelineItem> call(String itemId) {
    return _repository.watchTimelineItem(itemId);
  }
}
