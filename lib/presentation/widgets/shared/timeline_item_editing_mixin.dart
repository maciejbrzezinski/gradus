import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/text_commands.dart';
import '../timeline/item_type_selector_modal.dart';
import '../../cubits/focus/focus_cubit.dart';

/// Comprehensive mixin that provides complete editing functionality for timeline items
/// Combines smart text input, type selector overlay, and editing state management
mixin TimelineItemEditingMixin<T extends StatefulWidget> on State<T> {
  // === Smart Text Input ===
  late TextEditingController textController;
  late FocusNode focusNode;
  bool _isProcessingCommand = false;

  // === Type Selector Overlay ===
  OverlayEntry? _overlayEntry;
  bool _isInteractingWithOverlay = false;

  // === Editing State ===
  bool _isEditing = false;
  Timer? _debounceTimer;

  bool get isEditing => _isEditing;

  void setEditingState(bool editing) {
    setState(() {
      _isEditing = editing;
    });
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // === Smart Text Input Logic ===

  void onSmartTextChanged(String text) {
    // Skip command detection if we're currently processing a command
    if (_isProcessingCommand) return;

    // Check for slash command first
    if (CommandDetector.isSlashCommand(text)) {
      onSlashCommand();
      return;
    }

    // Check for text commands
    final cursorPosition = textController.selection.baseOffset;
    final commandMatch = CommandDetector.detectCommand(text, cursorPosition);

    if (commandMatch != null) {
      executeCommand(commandMatch);
    } else {
      // Regular text change
      onRegularTextChange(text);
    }
  }

  void executeCommand(CommandMatch match) async {
    // Clean the text by removing the command trigger
    final cleanText = match.remainingText.trim();

    // Transform the current item
    await transformCurrentItem(newType: match.command.targetType, newContent: cleanText);
  }

  // Method to safely clear slash and transform item
  void clearSlashAndTransform({required ItemType newType, required String newContent}) async {
    _isProcessingCommand = true;

    // Clear the slash immediately
    updateTextSilently(newContent);

    // Then transform the item
    await transformCurrentItem(newType: newType, newContent: newContent);

    // The focus will be automatically restored by the FocusCubit system
    // when the transformed widget rebuilds and checks shouldHaveFocus()

    _isProcessingCommand = false;
  }

  // Helper method to update text without triggering command detection
  void updateTextSilently(String text) {
    _removeListener();
    textController.text = text;
    _addListener();
  }

  // Helper method to set up the text controller with smart detection
  void setupSmartTextController({String? initialText}) {
    if (initialText != null) {
      textController.text = initialText;
    }
    _addListener();
  }

  void _addListener() {
    textController.addListener(_onTextControllerChanged);
  }

  void _removeListener() {
    textController.removeListener(_onTextControllerChanged);
  }

  void _onTextControllerChanged() {
    onSmartTextChanged(textController.text);
  }

  // === Type Selector Overlay Logic ===

  void onSlashCommand() {
    showTypeSelector();
  }

  void showTypeSelector() {
    _removeOverlay();
    _isInteractingWithOverlay = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          child: ItemTypeSelectorModal(
            onTypeSelected: (option) {
              _isInteractingWithOverlay = false;
              _removeOverlay();
              _transformFromTypeOption(option);
            },
            onDismiss: () {
              _isInteractingWithOverlay = false;
              _removeOverlay();
              focusNode.requestFocus();
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
    _isInteractingWithOverlay = false;
  }

  void _transformFromTypeOption(ItemTypeOption option) {
    // Always pass empty content so the transformed item will auto-focus
    if (option == ItemTypeOption.task) {
      clearSlashAndTransform(newType: ItemType.task, newContent: '');
    } else {
      final itemType = _itemTypeOptionToItemType(option);
      clearSlashAndTransform(newType: itemType, newContent: '');
    }

    // Ensure overlay interaction flag is cleared
    _isInteractingWithOverlay = false;
  }

  ItemType _itemTypeOptionToItemType(ItemTypeOption option) {
    switch (option) {
      case ItemTypeOption.text:
        return ItemType.textNote;
      case ItemTypeOption.headline1:
        return ItemType.headline1;
      case ItemTypeOption.headline2:
        return ItemType.headline2;
      case ItemTypeOption.headline3:
        return ItemType.headline3;
      case ItemTypeOption.task:
        return ItemType.task;
    }
  }

  // === Focus and Editing Management ===

  void onFocusGained(String itemId) {
    context.read<FocusCubit>().setFocus(itemId);
    setEditingState(true);
  }

  void onFocusLost() {
    _debounceTimer?.cancel();
    onRegularTextChange(textController.text);

    // Don't clear focus if we're interacting with overlay (e.g., type selector)
    // This preserves focus for restoration after transformation
    context.read<FocusCubit>().clearFocus();

    setEditingState(false);

    // If user is interacting with overlay, delay removal to allow selection
    if (_isInteractingWithOverlay) {
      Timer(const Duration(milliseconds: 100), () {
        if (!_isInteractingWithOverlay) {
          _removeOverlay();
        }
      });
    } else {
      _removeOverlay();
    }
  }

  void startEditing({String? initialText}) {
    setEditingState(true);
    if (initialText != null) {
      updateTextSilently(initialText);
    }
  }

  /// Check if this item should have focus based on FocusCubit state
  bool shouldHaveFocus(String itemId) {
    return context.read<FocusCubit>().isFocused(itemId);
  }

  // === Keyboard Input Widget Builder ===

  Widget buildEditingInput({required BuildContext context, required TextStyle? style, bool autofocus = true}) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onFocusLost();
        }
      },
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
              if (!isShiftPressed) {
                onEnterPressed(isShiftPressed: false);
              }
            } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (textController.text.isEmpty) {
                onBackspacePressed();
              }
            }
          }
        },
        child: TextFormField(
          controller: textController,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLines: null,
          style: style,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }

  /// Get the current item ID - to be implemented by concrete widgets
  String getCurrentItemId();

  // === Abstract methods to be implemented by concrete widgets ===

  /// Transform the current item to a new type with new content
  Future<void> transformCurrentItem({required ItemType newType, required String newContent});

  /// Handle regular text changes (non-command text)
  void onRegularTextChange(String text) {
    // Default implementation with debouncing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      saveChanges(text);
    });
  }

  /// Handle Enter key press
  void onEnterPressed({required bool isShiftPressed}) {
    // Default implementation - can be overridden
  }

  /// Handle Backspace key press when text is empty
  void onBackspacePressed() {
    // Default implementation - can be overridden
  }

  /// Save changes to the item - to be implemented by concrete widgets
  void saveChanges(String newContent);
}
