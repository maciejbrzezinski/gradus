import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mixin responsible for handling keyboard events
mixin KeyboardHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Handle keyboard events
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        if (!isShiftPressed) {
          // Prevent default Enter behavior and create new item
          onEnterPressed(isShiftPressed: false);
        }
        // Shift+Enter will be handled naturally by TextFormField for new lines
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        // Only handle backspace for item deletion when text is empty
        if (shouldHandleBackspace()) {
          onBackspacePressed();
        }
        // Otherwise, let TextFormField handle normal backspace
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (onArrowUp()) {
          // Navigation handled, prevent default behavior
          return;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (onArrowDown()) {
          // Navigation handled, prevent default behavior
          return;
        }
      }
    }
  }

  /// Handle Enter key press
  /// Returns true if the event was handled, false otherwise
  void onEnterPressed({required bool isShiftPressed}) {
    // Default implementation - can be overridden
  }

  /// Handle Backspace key press when text is empty
  /// Returns true if the event was handled, false otherwise
  void onBackspacePressed() {
    // Default implementation - can be overridden
  }

  /// Handle Arrow Up key press
  /// Returns true if navigation was handled, false if default behavior should continue
  bool onArrowUp() {
    // Default implementation - can be overridden
    return false;
  }

  /// Handle Arrow Down key press
  /// Returns true if navigation was handled, false if default behavior should continue
  bool onArrowDown() {
    // Default implementation - can be overridden
    return false;
  }

  /// Check if backspace should be handled for item deletion
  /// Override this to provide custom logic (e.g., check if text is empty)
  bool shouldHandleBackspace() {
    return false;
  }

  /// Build a KeyboardListener widget with the keyboard handler
  Widget buildKeyboardListener({
    required Widget child,
    FocusNode? focusNode,
  }) {
    return KeyboardListener(
      focusNode: focusNode ?? FocusNode(),
      onKeyEvent: handleKeyEvent,
      child: child,
    );
  }
}
