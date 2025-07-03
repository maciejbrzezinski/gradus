import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../entities/timeline_item.dart';
import '../../repositories/timeline_items_repository.dart';

@injectable
class DeleteTimelineItemUseCase {
  final TimelineItemsRepository _repository;

  DeleteTimelineItemUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String itemId) async {
    try {
      // First, get the item to check if it's a task with recurring links
      final itemResult = await _repository.getTimelineItem(itemId);
      
      return await itemResult.fold(
        (failure) => Left(failure),
        (timelineItem) async {
          // Check if it's a task and handle recurring task links
          await timelineItem.when(
            task: (task) async {
              // If this task has a previous recurring task, remove the forward link from it
              if (task.previousRecurringTaskId != null) {
                final prevTaskResult = await _repository.getTimelineItem(
                  task.previousRecurringTaskId!,
                );
                
                await prevTaskResult.fold(
                  (failure) => null, // Ignore error if previous task doesn't exist
                  (prevTimelineItem) async {
                    await prevTimelineItem.when(
                      task: (prevTask) async {
                        final updatedPrevTask = prevTask.copyWith(nextRecurringTaskId: null);
                        await _repository.updateTimelineItem(
                          TimelineItem.task(updatedPrevTask),
                        );
                      },
                      note: (note) async {
                        // Previous item is not a task, ignore
                      },
                    );
                  },
                );
              }
              
              // If this task has a next recurring task, remove the backward link from it
              if (task.nextRecurringTaskId != null) {
                final nextTaskResult = await _repository.getTimelineItem(
                  task.nextRecurringTaskId!,
                );
                
                await nextTaskResult.fold(
                  (failure) => null, // Ignore error if next task doesn't exist
                  (nextTimelineItem) async {
                    await nextTimelineItem.when(
                      task: (nextTask) async {
                        final updatedNextTask = nextTask.copyWith(previousRecurringTaskId: null);
                        await _repository.updateTimelineItem(
                          TimelineItem.task(updatedNextTask),
                        );
                      },
                      note: (note) async {
                        // Next item is not a task, ignore
                      },
                    );
                  },
                );
              }
            },
            note: (note) async {
              // Item is a note, no recurring task links to handle
            },
          );
          
          // Finally, delete the item
          return await _repository.deleteTimelineItem(itemId);
        },
      );
    } catch (e) {
      return Left(Failure.unknownFailure(message: 'Failed to delete timeline item: $e'));
    }
  }
}
