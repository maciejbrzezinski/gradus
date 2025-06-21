import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_parser.dart';
import '../../../domain/entities/day.dart';
import '../../../domain/entities/note_type.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import 'item_type_selector_modal.dart';

class AddItemWidget extends StatefulWidget {
  final Day day;
  final VoidCallback? onItemCreated;

  const AddItemWidget({
    super.key,
    required this.day,
    this.onItemCreated,
  });

  @override
  State<AddItemWidget> createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isActive = false;
  bool _isCreating = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _activate() {
    setState(() {
      _isActive = true;
    });
    _focusNode.requestFocus();
  }

  void _deactivate() {
    if (!_isCreating) {
      setState(() {
        _isActive = false;
      });
      _controller.clear();
      _removeOverlay();
    }
  }

  void _onTextChanged(String text) {
    final parseType = TextParser.parseInput(text);
    
    if (parseType == ItemCreationType.showTypeSelector && text.trim() == '/') {
      _showTypeSelector();
    } else {
      _removeOverlay();
    }
  }

  void _showTypeSelector() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).size.height * 0.3,
        child: Material(
          color: Colors.transparent,
          child: ItemTypeSelectorModal(
            onTypeSelected: (option) {
              _removeOverlay();
              _createItemFromTypeOption(option);
            },
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createItemFromTypeOption(ItemTypeOption option) {
    final content = _controller.text.trim();
    final cleanContent = content.startsWith('/') ? '' : content;

    if (option == ItemTypeOption.task) {
      _createTask(cleanContent.isEmpty ? 'New task' : cleanContent);
    } else {
      final noteType = ItemTypeSelectorModal.itemTypeOptionToNoteType(option);
      _createNote(cleanContent.isEmpty ? 'New note' : cleanContent, noteType);
    }
  }

  void _onSubmitted(String text) {
    if (text.trim().isEmpty) {
      _deactivate();
      return;
    }

    final parseType = TextParser.parseInput(text);
    
    switch (parseType) {
      case ItemCreationType.task:
        final cleanText = TextParser.cleanTaskText(text);
        _createTask(cleanText.isEmpty ? 'New task' : cleanText);
        break;
      case ItemCreationType.showTypeSelector:
        // This case is handled by _onTextChanged
        break;
      case ItemCreationType.note:
        final cleanText = TextParser.cleanNoteText(text);
        _createNote(cleanText, NoteType.text);
        break;
    }
  }

  Future<void> _createNote(String content, NoteType type) async {
    if (_isCreating) return;
    
    setState(() {
      _isCreating = true;
    });

    try {
      await context.read<TimelineCubit>().createNote(
        content: content,
        type: type,
        day: widget.day,
      );
      
      if (mounted) {
        _controller.clear();
        _deactivate();
        widget.onItemCreated?.call();
      }
    } catch (e) {
      // Handle error - could show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _createTask(String title) async {
    if (_isCreating) return;
    
    setState(() {
      _isCreating = true;
    });

    try {
      await context.read<TimelineCubit>().createTask(
        title: title,
        day: widget.day,
      );
      
      if (mounted) {
        _controller.clear();
        _deactivate();
        widget.onItemCreated?.call();
      }
    } catch (e) {
      // Handle error - could show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) {
      return GestureDetector(
        onTap: _activate,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 18,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                'Click to add item...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing24,
        vertical: AppTheme.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            onSubmitted: _onSubmitted,
            onTapOutside: (_) => _deactivate(),
            enabled: !_isCreating,
            decoration: InputDecoration(
              hintText: 'Type \'/\' for commands, \'[]\' for tasks...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: null,
          ),
          if (_isCreating)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacing8),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Creating...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
