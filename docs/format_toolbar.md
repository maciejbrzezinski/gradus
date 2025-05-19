# Format Toolbar Widget

The Format Toolbar widget provides a floating toolbar that appears when text is selected in a TextBlock, allowing users to apply formatting to the selected text.

## Overview

The Format Toolbar is a key component for enabling rich text editing in Gradus. It appears when a user selects text within a TextBlock and provides buttons for applying various formatting options such as bold, italic, underline, strikethrough, and text color.

## Implementation

```dart
// lib/widgets/format_toolbar.dart
import 'package:flutter/material.dart';
import '../models/text_formatting.dart';

class FormatToolbar extends StatelessWidget {
  final Function(TextFormatting) onFormatSelected;
  final Offset position;
  final TextFormatting currentFormatting;
  
  const FormatToolbar({
    Key? key,
    required this.onFormatSelected,
    required this.position,
    required this.currentFormatting,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy - 50, // Position above the text
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bold button
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: currentFormatting.bold ? Theme.of(context).primaryColor : null,
                ),
                onPressed: () => onFormatSelected(
                  currentFormatting.toggle('bold'),
                ),
                tooltip: 'Bold',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
              ),
              
              // Italic button
              IconButton(
                icon: Icon(
                  Icons.format_italic,
                  color: currentFormatting.italic ? Theme.of(context).primaryColor : null,
                ),
                onPressed: () => onFormatSelected(
                  currentFormatting.toggle('italic'),
                ),
                tooltip: 'Italic',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
              ),
              
              // Underline button
              IconButton(
                icon: Icon(
                  Icons.format_underlined,
                  color: currentFormatting.underline ? Theme.of(context).primaryColor : null,
                ),
                onPressed: () => onFormatSelected(
                  currentFormatting.toggle('underline'),
                ),
                tooltip: 'Underline',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
              ),
              
              // Strikethrough button
              IconButton(
                icon: Icon(
                  Icons.format_strikethrough,
                  color: currentFormatting.strikethrough ? Theme.of(context).primaryColor : null,
                ),
                onPressed: () => onFormatSelected(
                  currentFormatting.toggle('strikethrough'),
                ),
                tooltip: 'Strikethrough',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
              ),
              
              // Color picker button
              IconButton(
                icon: Icon(
                  Icons.format_color_text,
                  color: currentFormatting.color != null
                      ? Color(int.parse(currentFormatting.color!))
                      : null,
                ),
                onPressed: () => _showColorPicker(context),
                tooltip: 'Text Color',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 32, height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showColorPicker(BuildContext context) {
    // Show a color picker dialog
    // Implementation details omitted for brevity
    // When a color is selected, call onFormatSelected with the updated formatting
  }
}
```

## Usage

The Format Toolbar is used in conjunction with the TextBlockWidget to provide rich text editing capabilities:

```dart
class TextBlockWidgetState extends BlockWidgetState<TextBlockWidget> {
  TextBlock get textBlock => widget.block as TextBlock;
  TextSelection _selection = const TextSelection.collapsed(offset: 0);
  bool _showFormatToolbar = false;
  Offset _formatToolbarPosition = Offset.zero;
  
  // ... other methods ...
  
  void _updateSelection(TextSelection selection) {
    setState(() {
      _selection = selection;
      
      // Show format toolbar if text is selected
      if (!selection.isCollapsed) {
        _showFormatToolbar = true;
        
        // Calculate position for the toolbar
        final renderBox = context.findRenderObject() as RenderBox;
        final selectionRect = _getSelectionRect();
        _formatToolbarPosition = renderBox.localToGlobal(
          Offset(selectionRect.left, selectionRect.top),
        );
      } else {
        _showFormatToolbar = false;
      }
    });
  }
  
  void _applyFormatting(TextFormatting formatting) {
    if (!_selection.isCollapsed) {
      final start = _selection.start;
      final end = _selection.end;
      
      // Apply formatting to the selected text
      textBlock.applyFormatting(start, end, formatting);
      
      // Update the view
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Text block content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... text block content ...
            ],
          ),
        ),
        
        // Format toolbar
        if (_showFormatToolbar)
          FormatToolbar(
            onFormatSelected: _applyFormatting,
            position: _formatToolbarPosition,
            currentFormatting: textBlock.getFormattingAt(_selection.start),
          ),
      ],
    );
  }
}
```

## Integration with Block Controller

The BlockController is extended to support showing and hiding the Format Toolbar:

```dart
class BlockController {
  // ... other methods ...
  
  // Format toolbar state
  final ValueNotifier<bool> formatToolbarVisible = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> formatToolbarPosition = ValueNotifier<Offset>(Offset.zero);
  final ValueNotifier<TextFormatting> currentFormatting = ValueNotifier<TextFormatting>(TextFormatting.defaultFormatting);
  
  void showFormattingToolbar({
    required Offset position,
    required TextFormatting formatting,
  }) {
    formatToolbarPosition.value = position;
    currentFormatting.value = formatting;
    formatToolbarVisible.value = true;
  }
  
  void hideFormattingToolbar() {
    formatToolbarVisible.value = false;
  }
  
  void applyFormatting(String blockId, int start, int end, TextFormatting formatting) {
    // Find the block
    final block = _findBlock(blockId);
    if (block is TextBlock) {
      // Apply formatting to the selected text
      block.applyFormatting(start, end, formatting);
      
      // Notify listeners
      notifyListeners();
    }
  }
}
```

## User Experience

1. The user selects text in a TextBlock by dragging across the text
2. The Format Toolbar appears above the selected text
3. The user clicks on a formatting option (e.g., bold, italic, underline)
4. The selected text is updated with the chosen formatting
5. The Format Toolbar remains visible until the user clicks elsewhere or deselects the text

This implementation provides a seamless and intuitive way for users to apply rich text formatting to specific portions of text within a TextBlock.
