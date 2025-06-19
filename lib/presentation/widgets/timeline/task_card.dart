import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/domain/entities/timeline_item.dart';

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
    final dayId = widget.day.date.toIso8601String().split('T')[0];

    return Draggable<Map<String, dynamic>>(
      data: {'itemId': widget.task.id, 'fromDayId': dayId, 'type': 'task'},
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          child: _buildTaskContent(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildTaskCard(context)),
      child: _buildTaskCard(context),
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Container(padding: const EdgeInsets.all(12), child: _buildTaskContent(context)),
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
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
              color: Colors.green,
            ),
            child: widget.task.isCompleted ? Icon(Icons.check, size: 10, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isEditing
              ? Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      _onFocusLost();
                    }
                  },
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                      color: widget.task.isCompleted ? Colors.grey[600] : Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: _onTextChanged,
                  ),
                )
              : GestureDetector(
                  onTap: _startEditing,
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                      color: widget.task.isCompleted ? Colors.grey[600] : Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
        if (_shouldShowDaily()) ...[
          const SizedBox(width: 8),
          Text('daily', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 12)),
        ],
      ],
    );
  }

  bool _shouldShowDaily() {
    // Pokaż "daily" jeśli zadanie ma recurrence
    return widget.task.recurrence != null;
  }
}
