import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';
import 'task_card.dart';
import 'note_card.dart';

class TimelineItemWidget extends StatefulWidget {
  final String itemId;
  final Day day;

  const TimelineItemWidget({super.key, required this.itemId, required this.day});

  @override
  State<TimelineItemWidget> createState() => _TimelineItemWidgetState();
}

class _TimelineItemWidgetState extends State<TimelineItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        if (state is! TimelineLoaded) {
          return _buildLoadingWidget();
        }

        final item = state.cachedItems[widget.itemId];
        if (item == null) {
          // Item not yet cached, show minimal loading
          return _buildLoadingWidget();
        }

        return _buildItemWidget(item, widget.day);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing24,
        vertical: AppTheme.spacing8,
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(TimelineItem item, Day day) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spacing8,
              top: AppTheme.spacing8,
            ),
            child: AnimatedOpacity(
              opacity: _isHovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.drag_indicator,
                size: 16,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          // Timeline item content
          Expanded(
            child: item.when(
              task: (task) => TaskCard(task: task, day: day),
              note: (note) => NoteCard(note: note, day: day),
            ),
          ),
        ],
      ),
    );
  }
}
