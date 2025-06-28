import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/domain/entities/timeline_item.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/task.dart';
import '../../../core/utils/text_commands.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/focus/focus_cubit.dart';
import '../shared/timeline_item_editing_mixin.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Day day;

  const TaskCard({super.key, required this.task, required this.day});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TimelineItemEditingMixin {
  String _originalTitle = '';

  @override
  void initState() {
    super.initState();
    _originalTitle = widget.task.title;
    setupSmartTextController(initialText: _originalTitle);
    
    // Auto-enter edit mode if title is empty (newly created item)
    if (widget.task.title.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startEditing();
      });
    }
  }

  @override
  Future<void> transformCurrentItem({
    required ItemType newType,
    required String newContent,
  }) async {
    final timelineCubit = context.read<TimelineCubit>();
    
    if (newType == ItemType.task) {
      // Update task title (no transformation needed)
      saveChanges(newContent);
    } else if (newType.isHeadline || newType == ItemType.textNote) {
      // Transform task to note
      final noteType = newType.toNoteType();
      await timelineCubit.transformTaskToNote(
        taskId: widget.task.id,
        noteContent: newContent,
        noteType: noteType,
      );
    }
    
    // Don't exit edit mode - let the mixin handle focus management
  }

  @override
  void onEnterPressed({required bool isShiftPressed}) {
    if (!isShiftPressed) {
      // Regular Enter - create new task of same type
      final currentContent = getCurrentText().trim();
      if (currentContent.isNotEmpty) {

        // Save current changes first
        saveChanges(currentContent);
        _originalTitle = currentContent;
        
        // Create new task after current one and set focus to it
        context.read<TimelineCubit>().createItemAfterCurrent(
          currentItemId: widget.task.id,
          day: widget.day,
          itemType: ItemType.task,
          content: '',
        ).then((newItemId) {
          if (newItemId != null && mounted) {
            // Set focus to the newly created item
            context.read<FocusCubit>().setFocus(newItemId);
          }
          
          // Reset the flag and exit edit mode
          if (mounted) {
            setEditingState(false);
          }
        }).catchError((error) {
        });
      }
    }
    // Shift+Enter is handled by the TextFormField naturally (new line)
  }

  @override
  void onBackspacePressed() {
    final index = widget.day.itemIds.indexOf(widget.task.id);
    if (index > 0) {
      final previousItemId = widget.day.itemIds[index - 1];
      context.read<FocusCubit>().setFocus(previousItemId);
    }
    context
        .read<TimelineCubit>()
        .deleteItemFromDay(itemId: widget.task.id, day: widget.day);
  }

  @override
  void saveChanges(String newTitle) {
    if (newTitle.trim() != _originalTitle && newTitle.trim().isNotEmpty) {
      final updatedTask = widget.task.copyWith(title: newTitle.trim());
      context.read<TimelineCubit>().updateTimelineItem(TimelineItem.task(updatedTask));
      _originalTitle = newTitle.trim();
    }
  }

  void _startEditing() {
    onFocusGained(widget.task.id);
    startEditingMode(initialText: widget.task.title);
  }

  @override
  String getCurrentItemId() => widget.task.id;

  @override
  TextStyle getCurrentTextStyle() {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
      color: widget.task.isCompleted 
        ? AppTheme.textSecondary 
        : AppTheme.textPrimary,
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle(fontSize: 14);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, String?>(
      builder: (context, focusedItemId) {
        final shouldFocus = focusedItemId == widget.task.id;
        
        // Auto-focus if this item should have focus but isn't editing yet
        if (shouldFocus && !isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _startEditing();
            }
          });
        }
        
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
      },
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
            context.read<TimelineCubit>().updateTimelineItem(TimelineItem.task(updatedTask));
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
              isEditing
                ? buildEditingInput(
                    context: context,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                      color: widget.task.isCompleted 
                        ? AppTheme.textSecondary 
                        : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
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
