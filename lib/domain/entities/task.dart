import 'package:freezed_annotation/freezed_annotation.dart';

import 'item_type.dart';
import 'recurrence_rule.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  factory Task({
    required String id,
    @Default(ItemType.task) ItemType type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String title,
    @Default(false) bool isCompleted,
    String? description,
    RecurrenceRule? recurrence,
    String? nextRecurringTaskId,
    String? previousRecurringTaskId,
  }) = _Task;

  factory Task.create({
    required String title,
    bool isCompleted = false,
    String? description,
    RecurrenceRule? recurrence,
    String? nextRecurringTaskId,
    String? previousRecurringTaskId,
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
      nextRecurringTaskId: nextRecurringTaskId,
      previousRecurringTaskId: previousRecurringTaskId,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

