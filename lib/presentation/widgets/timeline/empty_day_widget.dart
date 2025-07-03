import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_type.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../cubits/timeline/timeline_cubit.dart';

class EmptyDayWidget extends StatelessWidget {
  final Day day;
  final VoidCallback? onItemCreated;

  const EmptyDayWidget({super.key, required this.day, this.onItemCreated});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _createFirstItem(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 32, color: AppTheme.primaryColor.withValues(alpha: 0.6)),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Click to add your first item',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFirstItem(BuildContext context) async {
    print('🔍 [EmptyDayWidget] Creating first text note for day: ${day.date}');

    try {
      // Create note entity using factory constructor
      final note = Note.create(
        content: '', // Empty content so it enters edit mode immediately
        noteType: NoteType.text,
      );
      final timelineItem = TimelineItem.note(note);

      await context.read<TimelineCubit>().createItem(
        day: day,
        timelineItem: timelineItem,
      );

      print('✅ [EmptyDayWidget] First note created successfully');

      // Wait a bit for the item to be created and rendered, then trigger callback
      if (context.mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          onItemCreated?.call();
        });
      }
    } catch (e) {
      print('❌ [EmptyDayWidget] Failed to create first note: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create item: $e'), backgroundColor: AppTheme.error));
      }
    }
  }
}
