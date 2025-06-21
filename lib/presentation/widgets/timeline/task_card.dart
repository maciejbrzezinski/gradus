import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/domain/entities/timeline_item.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/task.dart';
import '../../cubits/timeline_item/timeline_item_cubit.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Day day;

  const TaskCard({super.key, required this.task, required this.day});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isEditing = false;
  late TextEditingController _controller;
  Timer? _debounceTimer;
  String _originalTitle = '';

  @override
  void initState() {
    super.initState();
    _originalTitle = widget.task.title;
    _controller = TextEditingController(text: _originalTitle);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveChanges(value);
    });
  }

  void _onFocusLost() {
    _debounceTimer?.cancel();
    _saveChanges(_controller.text);
    setState(() => _isEditing = false);
  }

  void _saveChanges(String newTitle) {
    if (newTitle.trim() != _originalTitle && newTitle.trim().isNotEmpty) {
      final updatedTask = widget.task.copyWith(title: newTitle.trim());
      context.read<TimelineItemCubit>().updateItem(TimelineItem.task(updatedTask));
      _originalTitle = newTitle.trim();
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: {'itemId': widget.task.id, 'fromDay': widget.day, 'type': 'task'},
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1),
          ),
          child: _buildTaskContent(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildTaskCard(context)),
      child: _buildTaskCard(context),
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startEditing,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing4,
          ),
          child: _buildTaskContent(context),
        ),
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context, {bool isDragging = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final updatedTask = widget.task.copyWith(isCompleted: !widget.task.isCompleted);
            context.read<TimelineItemCubit>().updateItem(TimelineItem.task(updatedTask));
          },
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.task.isCompleted ? AppTheme.success : AppTheme.textSecondary,
                width: 2,
              ),
              color: widget.task.isCompleted ? AppTheme.success : Colors.transparent,
            ),
            child: widget.task.isCompleted 
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                ? Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _onFocusLost();
                      }
                    },
                    child: TextFormField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                        color: widget.task.isCompleted 
                          ? AppTheme.textSecondary 
                          : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: _onTextChanged,
                    ),
                  )
                : Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                      color: widget.task.isCompleted 
                        ? AppTheme.textSecondary 
                        : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
              if (_shouldShowDaily()) ...[
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    'Daily',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _shouldShowDaily() {
    // Pokaż "daily" jeśli zadanie ma recurrence
    return widget.task.recurrence != null;
  }
}
