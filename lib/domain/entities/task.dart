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

  factory Task.create({
    required String title,
    bool isCompleted = false,
    String? description,
    RecurrenceRule? recurrence,
  }) {
    final now = DateTime.now();
    return Task(
      id: 'task_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
      title: title,
      isCompleted: isCompleted,
      description: description,
      recurrence: recurrence,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
