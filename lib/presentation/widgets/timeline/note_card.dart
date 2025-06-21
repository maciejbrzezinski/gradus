import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradus/domain/entities/day.dart';
import 'package:gradus/domain/entities/timeline_item.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/note_type.dart';
import '../../cubits/timeline_item/timeline_item_cubit.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final Day day;

  const NoteCard({super.key, required this.note, required this.day});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isEditing = false;
  late TextEditingController _controller;
  Timer? _debounceTimer;
  String _originalContent = '';

  @override
  void initState() {
    super.initState();
    _originalContent = widget.note.content;
    _controller = TextEditingController(text: _originalContent);
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

  void _saveChanges(String newContent) {
    if (newContent.trim() != _originalContent && newContent.trim().isNotEmpty) {
      final updatedNote = widget.note.copyWith(content: newContent.trim());
      context.read<TimelineItemCubit>().updateItem(TimelineItem.note(updatedNote));
      _originalContent = newContent.trim();
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
      data: {'itemId': widget.note.id, 'fromDay': widget.day, 'type': 'note'},
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
          child: _buildNoteContent(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildNoteCard(context)),
      child: _buildNoteCard(context),
    );
  }

  Widget _buildNoteCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startEditing,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoteContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context, {bool isDragging = false}) {
    return _isEditing
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
              style: _getNoteTextStyle(context),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: _onTextChanged,
            ),
          )
        : Text(
            widget.note.content,
            style: _getNoteTextStyle(context),
          );
  }

  TextStyle? _getNoteTextStyle(BuildContext context) {
    switch (widget.note.type) {
      case NoteType.headline1:
        return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.3,
        );
      case NoteType.headline2:
        return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          height: 1.3,
        );
      case NoteType.headline3:
        return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          height: 1.4,
        );
      case NoteType.text:
        return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
          height: 1.5,
          fontWeight: FontWeight.w400,
        );
    }
  }
}
