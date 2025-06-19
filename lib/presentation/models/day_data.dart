import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/day.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/note.dart';

part 'day_data.freezed.dart';

// Helper class dla danych dnia z zadaniami i notatkami
@freezed
abstract class DayData with _$DayData {
  const factory DayData({
    required Day day,
    required List<Task> tasks,
    required List<Note> notes,
  }) = _DayData;
}