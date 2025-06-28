import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/domain/entities/day.dart';
import 'package:gradus/domain/entities/timeline_item.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_type.dart';
import '../../../core/utils/text_commands.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/focus/focus_cubit.dart';
import '../shared/timeline_item_editing_mixin.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final Day day;

  const NoteCard({super.key, required this.note, required this.day});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> with TimelineItemEditingMixin {
  String _originalContent = '';
  String _currentContent = '';

  @override
  void initState() {
    super.initState();
    _originalContent = widget.note.content;
    _currentContent = widget.note.content;
    setupSmartTextController(initialText: _originalContent);

    // Auto-enter edit mode if content is empty (newly created item)
    if (widget.note.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startEditing();
      });
    }
  }

  @override
  void didUpdateWidget(NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update current content when the widget updates (e.g., from stream)
    if (widget.note.content != oldWidget.note.content) {
      _currentContent = widget.note.content;
      _originalContent = widget.note.content;
    }
  }

  @override
  Future<void> transformCurrentItem({required ItemType newType, required String newContent}) async {
    final timelineCubit = context.read<TimelineCubit>();

    if (newType == ItemType.task) {
      // Transform note to task
      await timelineCubit.transformNoteToTask(noteId: widget.note.id, taskTitle: newContent);
    } else if (newType.isHeadline || newType == ItemType.textNote) {
      // Transform note type
      final noteType = newType.toNoteType();
      await timelineCubit.transformNoteType(noteId: widget.note.id, content: newContent, newType: noteType);
    }
    context.read<FocusCubit>().setFocus(widget.note.id);

    // Don't exit edit mode - let the mixin handle focus management
  }

  @override
  void onEnterPressed({required bool isShiftPressed}) {
    if (!isShiftPressed) {
      // Regular Enter - create new note of same type
      final currentContent = textController.text.trim();
      if (currentContent.isNotEmpty) {

        // Save current changes first and update the original content
        saveChanges(currentContent);
        _currentContent = currentContent;
        _originalContent = currentContent;

        // Determine the item type based on current note type
        final itemType = _noteTypeToItemType(widget.note.type);

        // Create new note after current one and set focus to it
        context.read<TimelineCubit>().createItemAfterCurrent(
          currentItemId: widget.note.id,
          day: widget.day,
          itemType: itemType,
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
    final index = widget.day.itemIds.indexOf(widget.note.id);
    if (index > 0) {
      final previousItemId = widget.day.itemIds[index - 1];
      context.read<FocusCubit>().setFocus(previousItemId);
    }
    context.read<TimelineCubit>().deleteItemFromDay(itemId: widget.note.id, day: widget.day);
  }

  @override
  void saveChanges(String newContent) {
    if (newContent.trim() != _originalContent && newContent.trim().isNotEmpty) {
      final updatedNote = widget.note.copyWith(content: newContent.trim());
      context.read<TimelineCubit>().updateTimelineItem(TimelineItem.note(updatedNote));
      _originalContent = newContent.trim();
      _currentContent = newContent.trim();
    }
  }

  ItemType _noteTypeToItemType(NoteType noteType) {
    switch (noteType) {
      case NoteType.text:
        return ItemType.textNote;
      case NoteType.headline1:
        return ItemType.headline1;
      case NoteType.headline2:
        return ItemType.headline2;
      case NoteType.headline3:
        return ItemType.headline3;
    }
  }

  void _startEditing() {
    onFocusGained(widget.note.id);
    startEditing(initialText: widget.note.content);
    focusNode.requestFocus();
  }

  @override
  String getCurrentItemId() => widget.note.id;

  @override
  TextStyle getCurrentTextStyle() {
    return _getNoteTextStyle(context) ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, String?>(
      builder: (context, focusedItemId) {
        final shouldFocus = focusedItemId == widget.note.id;

        // Auto-focus if this item should have focus but isn't editing yet
        if (shouldFocus && !isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _startEditing();
            }
          });
        }

        return Draggable<Map<String, dynamic>>(
          data: {'itemId': widget.note.id, 'fromDay': widget.day, 'type': 'note'},
          feedback: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: .3), width: 1),
            ),
            child: _buildNoteContent(context, isDragging: true),
          ),
          childWhenDragging: Opacity(opacity: 0.5, child: _buildNoteCard(context)),
          child: _buildNoteCard(context),
        );
      },
    );
  }

  Widget _buildNoteCard(BuildContext context) {
    return InkWell(
      onTap: _startEditing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: AppTheme.spacing4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildNoteContent(context)]),
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context, {bool isDragging = false}) {
    return isEditing
        ? buildEditingInput(context: context, style: _getNoteTextStyle(context))
        : Text(_currentContent, style: _getNoteTextStyle(context));
  }

  TextStyle? _getNoteTextStyle(BuildContext context) {
    switch (widget.note.type) {
      case NoteType.headline1:
        return Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, height: 1.3);
      case NoteType.headline2:
        return Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.3);
      case NoteType.headline3:
        return Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.4);
      case NoteType.text:
        return Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary, height: 1.5, fontWeight: FontWeight.w400);
    }
  }
}
