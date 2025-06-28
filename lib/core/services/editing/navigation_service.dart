import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/day.dart';

/// Service responsible for handling navigation between timeline items
@injectable
class NavigationService {
  /// Check if cursor is on the first line of text (considering visual line wrapping)
  bool isOnFirstLine(String text, int cursorPosition, RenderEditable? renderEditable) {
    // If cursor position is invalid, assume first line
    if (cursorPosition < 0 || cursorPosition > text.length) {
      return true;
    }

    // If text is empty, always first line
    if (text.isEmpty) {
      return true;
    }

    try {
      // Try using the real RenderEditable from the TextFormField
      return _isOnFirstLineUsingRenderEditable(cursorPosition, renderEditable);
    } catch (e) {
      // Fallback to logical line detection if RenderEditable fails
      return _isOnFirstLogicalLine(text, cursorPosition);
    }
  }

  /// Check if cursor is on the last line of text (considering visual line wrapping)
  bool isOnLastLine(String text, int cursorPosition, RenderEditable? renderEditable) {
    // If cursor position is invalid, assume last line
    if (cursorPosition < 0 || cursorPosition > text.length) {
      return true;
    }

    // If text is empty, always last line
    if (text.isEmpty) {
      return true;
    }

    try {
      // Try using the real RenderEditable from the TextFormField
      return _isOnLastLineUsingRenderEditable(cursorPosition, renderEditable);
    } catch (e) {
      // Fallback to logical line detection if RenderEditable fails
      return _isOnLastLogicalLine(text, cursorPosition);
    }
  }

  /// Find RenderEditable in the render tree
  RenderEditable? findRenderEditable(RenderObject? renderObject) {
    if (renderObject == null) return null;
    
    // Check if this is already RenderEditable
    if (renderObject is RenderEditable) {
      return renderObject;
    }
    
    // Search through children
    RenderEditable? found;
    renderObject.visitChildren((child) {
      found ??= findRenderEditable(child);
    });
    
    return found;
  }

  /// Check if cursor is on first line using the real RenderEditable
  bool _isOnFirstLineUsingRenderEditable(int cursorPosition, RenderEditable? renderEditable) {
    if (renderEditable == null) {
      throw Exception('RenderEditable is null');
    }
    
    final currentPosition = TextPosition(offset: cursorPosition);
    
    // Try to get position above current cursor
    final positionAbove = renderEditable.getTextPositionAbove(currentPosition);
    
    // If position above is the same as current position, we're on the first line
    return positionAbove.offset == currentPosition.offset;
  }

  /// Check if cursor is on last line using the real RenderEditable
  bool _isOnLastLineUsingRenderEditable(int cursorPosition, RenderEditable? renderEditable) {
    if (renderEditable == null) {
      throw Exception('RenderEditable is null');
    }
    
    final currentPosition = TextPosition(offset: cursorPosition);
    
    // Try to get position below current cursor
    final positionBelow = renderEditable.getTextPositionBelow(currentPosition);
    
    // If position below is the same as current position, we're on the last line
    return positionBelow.offset == currentPosition.offset;
  }

  /// Fallback: Check if cursor is on the first logical line (only considers \n)
  bool _isOnFirstLogicalLine(String text, int cursorPosition) {
    if (text.isEmpty || !text.contains('\n')) {
      return true;
    }

    // Find the line number of the cursor position
    final lineNumber = _getLogicalLineNumber(text, cursorPosition);
    return lineNumber == 0; // First line is line 0
  }

  /// Fallback: Check if cursor is on the last logical line (only considers \n)
  bool _isOnLastLogicalLine(String text, int cursorPosition) {
    if (text.isEmpty || !text.contains('\n')) {
      return true;
    }

    // Find the line number of the cursor position and total lines
    final lineNumber = _getLogicalLineNumber(text, cursorPosition);
    final totalLines = text.split('\n').length;
    return lineNumber == totalLines - 1; // Last line index
  }

  /// Get the logical line number (0-based) for a given cursor position
  int _getLogicalLineNumber(String text, int cursorPosition) {
    if (cursorPosition <= 0) return 0;

    int lineNumber = 0;
    for (int i = 0; i < cursorPosition && i < text.length; i++) {
      if (text[i] == '\n') {
        lineNumber++;
      }
    }
    return lineNumber;
  }

  /// Find the previous item ID in chronological order across all days
  String? findPreviousItemId(String currentItemId, List<Day> days) {
    // Sort days by date
    final sortedDays = List<Day>.from(days)..sort((a, b) => a.date.compareTo(b.date));
    
    String? previousItemId;
    
    for (final day in sortedDays) {
      for (final itemId in day.itemIds) {
        if (itemId == currentItemId) {
          return previousItemId; // Return the item we found just before current
        }
        previousItemId = itemId; // Keep track of the previous item
      }
    }
    
    return null; // Current item not found or it's the first item
  }

  /// Find the next item ID in chronological order across all days
  String? findNextItemId(String currentItemId, List<Day> days) {
    // Sort days by date
    final sortedDays = List<Day>.from(days)..sort((a, b) => a.date.compareTo(b.date));
    
    bool foundCurrent = false;
    
    for (final day in sortedDays) {
      for (final itemId in day.itemIds) {
        if (foundCurrent) {
          return itemId; // Return the first item after current
        }
        if (itemId == currentItemId) {
          foundCurrent = true;
        }
      }
    }
    
    return null; // Current item not found or it's the last item
  }

  /// Position cursor at the end of text
  void positionCursorAtEnd(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  /// Position cursor at the beginning of text
  void positionCursorAtBeginning(TextEditingController controller) {
    controller.selection = TextSelection.fromPosition(
      const TextPosition(offset: 0),
    );
  }
}
