import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/day.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../cubits/timeline_item/timeline_item_cubit.dart';
import '../../cubits/timeline_item/timeline_item_cubit_factory.dart';
import '../../cubits/timeline_item/timeline_item_state.dart';
import '../../../core/di/injection.dart';
import 'task_card.dart';
import 'note_card.dart';

class TimelineItemWidget extends StatelessWidget {
  final String itemId;
  final Day day;

  const TimelineItemWidget({super.key, required this.itemId, required this.day});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TimelineItemCubitFactory>().create(itemId),
      child: BlocBuilder<TimelineItemCubit, TimelineItemState>(
        builder: (context, state) {
          return state.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            loaded: (item) => _buildItemWidget(item, day),
            error: (failure) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading item',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        failure.message,
                        style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemWidget(TimelineItem item, Day day) {
    return item.when(
      task: (task) => TaskCard(task: task, day: day),
      note: (note) => NoteCard(note: note, day: day),
    );
  }
}
