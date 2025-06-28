import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../utils/text_commands.dart';

/// Service responsible for managing text input with smart command detection
@injectable
class TextInputService {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isProcessingCommand = false;
  StreamSubscription? _textSubscription;

  // Callbacks
  Function(String)? onTextChanged;
  Function(CommandMatch)? onCommandDetected;
  VoidCallback? onSlashCommand;

  TextEditingController get textController => _textController;
  FocusNode get focusNode => _focusNode;
  bool get isProcessingCommand => _isProcessingCommand;

  /// Initialize the service with optional initial text
  void initialize({String? initialText}) {
    _textController = TextEditingController(text: initialText ?? '');
    _focusNode = FocusNode();
    _setupTextListener();
  }

  /// Setup text change listener with smart command detection
  void _setupTextListener() {
    _textController.addListener(_onTextControllerChanged);
  }

  /// Handle text controller changes with command detection
  void _onTextControllerChanged() {
    final text = _textController.text;
    
    // Skip command detection if we're currently processing a command
    if (_isProcessingCommand) return;

    // Check for slash command first
    if (CommandDetector.isSlashCommand(text)) {
      onSlashCommand?.call();
      return;
    }

    // Check for text commands
    final cursorPosition = _textController.selection.baseOffset;
    final commandMatch = CommandDetector.detectCommand(text, cursorPosition);

    if (commandMatch != null) {
      onCommandDetected?.call(commandMatch);
    } else {
      // Regular text change
      onTextChanged?.call(text);
    }
  }

  /// Update text without triggering command detection
  void updateTextSilently(String text) {
    _isProcessingCommand = true;
    _removeListener();
    _textController.text = text;
    _addListener();
    _isProcessingCommand = false;
  }

  /// Set cursor position
  void setCursorPosition(int position) {
    final clampedPosition = position.clamp(0, _textController.text.length);
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: clampedPosition),
    );
  }

  /// Position cursor at the end of text
  void positionCursorAtEnd() {
    if (_textController.text.isNotEmpty) {
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  /// Position cursor at the beginning of text
  void positionCursorAtBeginning() {
    _textController.selection = TextSelection.fromPosition(
      const TextPosition(offset: 0),
    );
  }

  /// Get current cursor position
  int get cursorPosition => _textController.selection.baseOffset;

  /// Check if text is empty
  bool get isEmpty => _textController.text.isEmpty;

  /// Get current text
  String get text => _textController.text;

  /// Clear text
  void clear() {
    updateTextSilently('');
  }

  /// Add text change listener
  void _addListener() {
    _textController.addListener(_onTextControllerChanged);
  }

  /// Remove text change listener
  void _removeListener() {
    _textController.removeListener(_onTextControllerChanged);
  }

  /// Request focus for the text field
  void requestFocus() {
    _focusNode.requestFocus();
  }

  /// Check if the text field has focus
  bool get hasFocus => _focusNode.hasFocus;

  /// Dispose of resources
  void dispose() {
    _textSubscription?.cancel();
    _removeListener();
    _textController.dispose();
    _focusNode.dispose();
  }
}
