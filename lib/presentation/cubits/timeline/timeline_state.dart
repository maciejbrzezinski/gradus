import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/timeline_item.dart';

part 'timeline_state.freezed.dart';

@freezed
class TimelineState with _$TimelineState {
  const factory TimelineState.initial() = TimelineInitial;
  const factory TimelineState.loading() = TimelineLoading;
  const factory TimelineState.loaded({
    required List<Day> days,
    required List<TimelineItem> items,
    required DateTime startDate,
    required DateTime endDate,
    required String? currentProjectId,
  }) = TimelineLoaded;
  const factory TimelineState.error({
    required Failure failure,
  }) = TimelineError;
}
