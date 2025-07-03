import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../entities/day.dart';
import '../../entities/task.dart' as entities;
import '../../entities/recurrence_rule.dart';
import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';
import '../../repositories/days_repository.dart';
import '../../../core/error/failure.dart';

@injectable
class CompleteRecurringTaskUseCase {
  final TimelineItemsRepository _timelineItemsRepository;
  final DaysRepository _daysRepository;

  CompleteRecurringTaskUseCase(this._timelineItemsRepository, this._daysRepository);

  Future<Either<Failure, Unit>> call({
    required entities.Task originalTask,
    required Day currentDay,
    required bool isCompleted,
  }) async {
    try {
      // First, update the current task completion status
      final task = originalTask.copyWith(isCompleted: isCompleted, updatedAt: DateTime.now());

      // If task is being completed and has recurrence, create next occurrence
      if (isCompleted && task.recurrence != null) {
        // Check if next recurring task already exists
        if (task.nextRecurringTaskId != null) {
          // Next task already exists - do nothing
          return const Right(unit);
        }

        final nextDate = _calculateNextDate(currentDay.date, task.recurrence!);

        // Check if we should create next occurrence
        if (_shouldCreateNextOccurrence(task.recurrence!, nextDate)) {
          await _createNextOccurrenceWithLinks(task, nextDate, currentDay.projectId);
        } else {
          await _timelineItemsRepository.updateTimelineItem(TimelineItem.task(task));
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknownFailure(message: 'Failed to complete recurring task: $e'));
    }
  }

  DateTime _calculateNextDate(DateTime currentDate, RecurrenceRule rule) {
    switch (rule.type) {
      case RecurrenceType.daily:
        return currentDate.add(Duration(days: rule.interval));
      case RecurrenceType.weekly:
        return currentDate.add(Duration(days: 7 * rule.interval));
      case RecurrenceType.monthly:
        return DateTime(currentDate.year, currentDate.month + rule.interval, currentDate.day);
      case RecurrenceType.yearly:
        return DateTime(currentDate.year + rule.interval, currentDate.month, currentDate.day);
    }
  }

  bool _shouldCreateNextOccurrence(RecurrenceRule rule, DateTime nextDate) {
    // Check end date constraint
    if (rule.endDate != null && nextDate.isAfter(rule.endDate!)) {
      return false;
    }

    // Check count constraint (this would require tracking occurrence count)
    // For now, we'll skip count-based constraints as it requires additional state

    return true;
  }

  Future<void> _createNextOccurrenceWithLinks(entities.Task originalTask, DateTime nextDate, String projectId) async {
    // Create new task for next occurrence with backward link
    final nextTask = entities.Task(
      id: _generateTaskId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: originalTask.title,
      isCompleted: false,
      description: originalTask.description,
      recurrence: originalTask.recurrence,
      previousRecurringTaskId: originalTask.id,
    );

    // Add new task to timeline items
    await _timelineItemsRepository.createTimelineItem(TimelineItem.task(nextTask));

    // Update original task with forward link
    final updatedOriginalTask = originalTask.copyWith(nextRecurringTaskId: nextTask.id);
    await _timelineItemsRepository.updateTimelineItem(TimelineItem.task(updatedOriginalTask));

    // Create or get the day for next occurrence
    final nextDay = Day(date: nextDate, projectId: projectId, itemIds: [], updatedAt: DateTime.now());

    // Add task to the day
    try {
      // Try to get existing day first
      final daysResult = await _daysRepository.getDays(projectId: projectId, startDate: nextDate, endDate: nextDate);

      await daysResult.fold(
        (failure) async {
          // If getting days failed, we can't proceed
          print('Failed to get days for next occurrence: $failure');
        },
        (days) async {
          if (days.isEmpty) {
            // Day doesn't exist, create it with the task
            final newDay = nextDay.copyWith(itemIds: [nextTask.id], updatedAt: DateTime.now());
            await _daysRepository.updateDay(newDay);
          } else {
            // Day exists, add task to it
            final existingDay = days.first;
            final updatedDay = existingDay.copyWith(
              itemIds: [...existingDay.itemIds, nextTask.id],
              updatedAt: DateTime.now(),
            );
            await _daysRepository.updateDay(updatedDay);
          }
        },
      );
    } catch (e) {
      print('Error creating next occurrence: $e');
    }
  }

  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}';
  }
}
