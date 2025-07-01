import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/timeline_item.dart';

part 'timeline_state.freezed.dart';

@freezed
class TimelineState with _$TimelineState {
  const factory TimelineState.initial() = TimelineInitial;
  const factory TimelineState.loading() = TimelineLoading;
  const factory TimelineState.loaded({
    required Project? selectedProject,
    required List<Project> availableProjects,
    required List<Day> days,
    required List<TimelineItem> items,
    required DateTime startDate,
    required DateTime endDate,
  }) = TimelineLoaded;
  const factory TimelineState.error({
    required Failure failure,
  }) = TimelineError;
}

extension TimelineStateExtensions on TimelineState {
  List<Day> getDaysForProject(String projectId) {
    return maybeWhen(
      loaded: (_, __, days, ___, ____, _____) {
        return days
          .where((day) => day.projectId == projectId)
          .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      },
      orElse: () => [],
    );
  }
  
  List<TimelineItem> getItemsForDay(Day day) {
    return maybeWhen(
      loaded: (_, __, ___, items, ____, _____) {
        return day.itemIds
          .map((id) => items.cast<TimelineItem?>().firstWhere(
            (item) => item?.id == id,
            orElse: () => null,
          ))
          .where((item) => item != null)
          .cast<TimelineItem>()
          .toList();
      },
      orElse: () => [],
    );
  }
  
  TimelineItem? getItemById(String itemId) {
    return maybeWhen(
      loaded: (_, __, ___, items, ____, _____) {
        return items.cast<TimelineItem?>().firstWhere(
          (item) => item?.id == itemId,
          orElse: () => null,
        );
      },
      orElse: () => null,
    );
  }
}
