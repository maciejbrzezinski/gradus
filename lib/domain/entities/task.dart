import 'package:freezed_annotation/freezed_annotation.dart';

import 'recurrence_rule.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
    @Default(false) bool isCompleted,
    String? description,
    RecurrenceRule? recurrence,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
