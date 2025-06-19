import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/timeline_item.dart';

part 'timeline_item_state.freezed.dart';

@freezed
class TimelineItemState with _$TimelineItemState {
  const factory TimelineItemState.loading() = TimelineItemLoading;
  const factory TimelineItemState.loaded(TimelineItem item) = TimelineItemLoaded;
  const factory TimelineItemState.error(Failure failure) = TimelineItemError;
}
