import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/project.dart';

part 'timeline_state.freezed.dart';

@freezed
class TimelineState with _$TimelineState {
  const factory TimelineState.initial() = TimelineInitial;
  const factory TimelineState.loading() = TimelineLoading;
  const factory TimelineState.loaded({
    required List<Day> days,
    required Project? selectedProject,
    required List<Project> availableProjects,
    @Default({}) Set<String> pendingOperations,
    @Default({}) Map<String, Day> optimisticDays,
  }) = TimelineLoaded;
  const factory TimelineState.error({
    required Failure failure,
  }) = TimelineError;
}

extension TimelineStateExtensions on TimelineState {
  /// Get the effective days list with optimistic updates applied
  List<Day> get effectiveDays {
    return when(
      initial: () => [],
      loading: () => [],
      error: (_) => [],
      loaded: (days, _, __, ___, optimisticDays) {
        if (optimisticDays.isEmpty) return days;
        
        // Apply optimistic updates to the days
        final Map<String, Day> dayMap = {
          for (final day in days) _getDayKey(day): day
        };
        
        // Override with optimistic updates
        dayMap.addAll(optimisticDays);
        
        return dayMap.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      },
    );
  }
  
  String _getDayKey(Day day) => '${day.projectId}_${day.date.toIso8601String().split('T')[0]}';
}
