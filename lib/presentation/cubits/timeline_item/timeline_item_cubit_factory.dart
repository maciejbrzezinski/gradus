import 'package:injectable/injectable.dart';

import '../../../domain/usecases/timeline_items/get_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/watch_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/update_timeline_item_usecase.dart';
import '../../../domain/usecases/timeline_items/delete_timeline_item_usecase.dart';
import 'timeline_item_cubit.dart';

@injectable
class TimelineItemCubitFactory {
  final GetTimelineItemUseCase _getTimelineItemUseCase;
  final WatchTimelineItemUseCase _watchTimelineItemUseCase;
  final UpdateTimelineItemUseCase _updateTimelineItemUseCase;
  final DeleteTimelineItemUseCase _deleteTimelineItemUseCase;

  TimelineItemCubitFactory(
    this._getTimelineItemUseCase,
    this._watchTimelineItemUseCase,
    this._updateTimelineItemUseCase,
    this._deleteTimelineItemUseCase,
  );

  TimelineItemCubit create(String itemId) {
    return TimelineItemCubit(
      itemId: itemId,
      getTimelineItemUseCase: _getTimelineItemUseCase,
      watchTimelineItemUseCase: _watchTimelineItemUseCase,
      updateTimelineItemUseCase: _updateTimelineItemUseCase,
      deleteTimelineItemUseCase: _deleteTimelineItemUseCase,
    );
  }
}
