import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/text_commands.dart';
import '../timeline/item_type_selector_modal.dart';
import '../../cubits/focus/focus_cubit.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';

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
  bool _isCreatingNewItem = false;

  // === Arrow Key Navigation State ===
  int? _cursorPositionBeforeArrow;
  bool _isProcessingArrowKey = false;

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

    // Skip regular text change processing if we're creating a new item
    if (!_isCreatingNewItem) {
      onRegularTextChange(textController.text);
    }

    // Don't clear focus if we're interacting with overlay (e.g., type selector)
    // This preserves focus for restoration after transformation
    if (!_isCreatingNewItem) {
      context.read<FocusCubit>().clearFocus();
    }

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

  // === Arrow Key Navigation ===

  /// Handle arrow up key press
  /// Returns true if navigation was handled, false if default behavior should continue
  bool _handleArrowUp() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = textController.selection.baseOffset;
    final text = textController.text;

    // Check if we're on the first line - if not, let TextFormField handle it naturally
    if (!_isOnFirstLine(text, currentPosition)) {
      return false; // Let TextFormField handle normal line navigation
    }

    _isProcessingArrowKey = true;
    _cursorPositionBeforeArrow = currentPosition;

    // Schedule check after TextFormField processes the arrow key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNavigationAfterArrowKey(isUpArrow: true);
    });

    return false; // Always let TextFormField handle the key first
  }

  /// Handle arrow down key press
  /// Returns true if navigation was handled, false if default behavior should continue
  bool _handleArrowDown() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = textController.selection.baseOffset;
    final text = textController.text;

    // Check if we're on the last line - if not, let TextFormField handle it naturally
    if (!_isOnLastLine(text, currentPosition)) {
      return false; // Let TextFormField handle normal line navigation
    }

    _isProcessingArrowKey = true;
    _cursorPositionBeforeArrow = currentPosition;

    // Schedule check after TextFormField processes the arrow key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNavigationAfterArrowKey(isUpArrow: false);
    });

    return false; // Always let TextFormField handle the key first
  }

  /// Check if navigation should happen after arrow key was processed
  void _checkForNavigationAfterArrowKey({required bool isUpArrow}) {
    if (!_isProcessingArrowKey) return;

    final cursorPositionAfterArrow = textController.selection.baseOffset;
    final text = textController.text;

    // Debug information
    print('DEBUG: Arrow navigation check');
    print('  Direction: ${isUpArrow ? "UP" : "DOWN"}');
    print('  Text: "$text"');
    print('  Cursor before: $_cursorPositionBeforeArrow');
    print('  Cursor after: $cursorPositionAfterArrow');

    // Check if cursor position didn't change (meaning we hit a boundary)
    bool shouldNavigate = false;

    if (_cursorPositionBeforeArrow != null) {
      final cursorDidntMove = cursorPositionAfterArrow == _cursorPositionBeforeArrow;

      if (isUpArrow) {
        final isOnFirstLine = _isOnFirstLine(text, cursorPositionAfterArrow);
        print('  Cursor didn\'t move: $cursorDidntMove');
        print('  Is on first line: $isOnFirstLine');
        // If cursor didn't move up and we're on first line, navigate to previous item
        shouldNavigate = cursorDidntMove && isOnFirstLine;
      } else {
        final isOnLastLine = _isOnLastLine(text, cursorPositionAfterArrow);
        print('  Cursor didn\'t move: $cursorDidntMove');
        print('  Is on last line: $isOnLastLine');
        // If cursor didn't move down and we're on last line, navigate to next item
        shouldNavigate = cursorDidntMove && isOnLastLine;
      }
    }

    print('  Should navigate: $shouldNavigate');

    if (shouldNavigate) {
      print('  Navigating to ${isUpArrow ? "previous" : "next"} item');
      if (isUpArrow) {
        _navigateToPreviousItem();
      } else {
        _navigateToNextItem();
      }
    }

    // Reset state
    _isProcessingArrowKey = false;
    _cursorPositionBeforeArrow = null;
  }

  /// Check if cursor is on the first line of text (considering visual line wrapping)
  bool _isOnFirstLine(String text, int cursorPosition) {
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
      return _isOnFirstLineUsingRenderEditable(cursorPosition);
    } catch (e) {
      print('DEBUG: RenderEditable failed, using fallback: $e');
      // Fallback to logical line detection if RenderEditable fails
      return _isOnFirstLogicalLine(text, cursorPosition);
    }
  }

  /// Check if cursor is on the last line of text (considering visual line wrapping)
  bool _isOnLastLine(String text, int cursorPosition) {
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
      return _isOnLastLineUsingRenderEditable(cursorPosition);
    } catch (e) {
      print('DEBUG: RenderEditable failed, using fallback: $e');
      // Fallback to logical line detection if RenderEditable fails
      return _isOnLastLogicalLine(text, cursorPosition);
    }
  }

  /// Find RenderEditable in the render tree (it might be wrapped in other render objects)
  RenderEditable? _findRenderEditable(RenderObject? renderObject) {
    if (renderObject == null) return null;
    
    // Check if this is already RenderEditable
    if (renderObject is RenderEditable) {
      return renderObject;
    }
    
    // Search through children
    RenderEditable? found;
    renderObject.visitChildren((child) {
      found ??= _findRenderEditable(child);
    });
    
    return found;
  }

  /// Check if cursor is on first line using the real RenderEditable
  bool _isOnFirstLineUsingRenderEditable(int cursorPosition) {
    // Get the RenderEditable from the focus node's context
    final renderObject = focusNode.context?.findRenderObject();
    final renderEditable = _findRenderEditable(renderObject);
    
    if (renderEditable == null) {
      throw Exception('Could not find RenderEditable in render tree');
    }
    
    final currentPosition = TextPosition(offset: cursorPosition);
    
    // Try to get position above current cursor
    final positionAbove = renderEditable.getTextPositionAbove(currentPosition);
    
    // If position above is the same as current position, we're on the first line
    final isOnFirstLine = positionAbove.offset == currentPosition.offset;
    
    print('DEBUG: RenderEditable first line check');
    print('  Current position: ${currentPosition.offset}');
    print('  Position above: ${positionAbove.offset}');
    print('  Is on first line: $isOnFirstLine');
    
    return isOnFirstLine;
  }

  /// Check if cursor is on last line using the real RenderEditable
  bool _isOnLastLineUsingRenderEditable(int cursorPosition) {
    // Get the RenderEditable from the focus node's context
    final renderObject = focusNode.context?.findRenderObject();
    final renderEditable = _findRenderEditable(renderObject);
    
    if (renderEditable == null) {
      throw Exception('Could not find RenderEditable in render tree');
    }
    
    final currentPosition = TextPosition(offset: cursorPosition);
    
    // Try to get position below current cursor
    final positionBelow = renderEditable.getTextPositionBelow(currentPosition);
    
    // If position below is the same as current position, we're on the last line
    final isOnLastLine = positionBelow.offset == currentPosition.offset;
    
    print('DEBUG: RenderEditable last line check');
    print('  Current position: ${currentPosition.offset}');
    print('  Position below: ${positionBelow.offset}');
    print('  Is on last line: $isOnLastLine');
    
    return isOnLastLine;
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

  /// Get the current text style for the text field
  /// Can be overridden by concrete implementations for accurate line calculations
  TextStyle getCurrentTextStyle() {
    // Try to get the style from the current context
    // This will be overridden by concrete implementations if needed
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }


  /// Navigate to the previous item in the timeline
  void _navigateToPreviousItem() {
    // Remember current cursor X position before navigation
    _rememberCursorXPosition();
    
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final previousItemId = focusCubit.findPreviousItemId(getCurrentItemId(), currentState.effectiveDays);

      if (previousItemId != null) {
        focusCubit.setFocus(previousItemId);
        // Schedule cursor positioning after the widget rebuilds and focuses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _positionCursorAtLastLineWithPreferredX();
        });
      }
    }
  }

  /// Navigate to the next item in the timeline
  void _navigateToNextItem() {
    // Remember current cursor X position before navigation
    _rememberCursorXPosition();
    
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final nextItemId = focusCubit.findNextItemId(getCurrentItemId(), currentState.effectiveDays);

      if (nextItemId != null) {
        focusCubit.setFocus(nextItemId);
        // Schedule cursor positioning after the widget rebuilds and focuses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _positionCursorAtFirstLineWithPreferredX();
        });
      }
    }
  }

  /// Remember the current cursor X position for cross-item navigation
  void _rememberCursorXPosition() {
    // For now, we'll use simple positioning without X preservation
    // This can be enhanced later when we find the correct RenderEditable methods
  }

  /// Position cursor at the first line with preferred X position
  void _positionCursorAtFirstLineWithPreferredX() {
    // For now, just position at beginning
    // This fixes the main navigation issue
    _positionCursorAtBeginning();
  }

  /// Position cursor at the last line with preferred X position
  void _positionCursorAtLastLineWithPreferredX() {
    // For now, just position at end
    // This fixes the main navigation issue
    _positionCursorAtEnd();
  }

  /// Position cursor at the end of the text
  void _positionCursorAtEnd() {
    if (textController.text.isNotEmpty) {
      textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
    }
  }

  /// Position cursor at the beginning of the text
  void _positionCursorAtBeginning() {
    textController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
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
                // Prevent default Enter behavior and create new item
                onEnterPressed(isShiftPressed: false);
              }
              // Shift+Enter will be handled naturally by TextFormField for new lines
            } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
              // Only handle backspace for item deletion when text is empty
              if (textController.text.isEmpty) {
                onBackspacePressed();
              }
              // Otherwise, let TextFormField handle normal backspace
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (_handleArrowUp()) {
                // Navigation handled, prevent default behavior
                return;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_handleArrowDown()) {
                // Navigation handled, prevent default behavior
                return;
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
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // Handle Enter key press when field is submitted
            onEnterPressed(isShiftPressed: false);
          },
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
