import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/editing/timeline_item_editing_controller.dart';
import '../../../core/utils/text_commands.dart';
import '../../cubits/focus/focus_cubit.dart';
import '../../cubits/timeline/timeline_cubit.dart';
import '../../cubits/timeline/timeline_state.dart';

/// Simplified mixin that coordinates all editing functionality through services
mixin TimelineItemEditingMixin<T extends StatefulWidget> on State<T> {
  
  late TimelineItemEditingController _controller;
  
  // Editing state
  bool _isEditing = false;
  Timer? _debounceTimer;
  bool _isCreatingNewItem = false;

  // Navigation state
  int? _cursorPositionBeforeArrow;
  bool _isProcessingArrowKey = false;

  bool get isEditing => _isEditing;
  bool get isCreatingNewItem => _isCreatingNewItem;

  @override
  void initState() {
    super.initState();
    _controller = GetIt.instance<TimelineItemEditingController>();
    _setupController();
  }

  /// Setup the controller with callbacks
  void _setupController() {
    _controller.onTextChanged = (text) {
      onRegularTextChange(text);
    };

    _controller.onTransformItem = ({required ItemType newType, required String newContent}) {
      transformCurrentItem(newType: newType, newContent: newContent);
    };

    _controller.onSlashCommand = () {
      _controller.showTypeSelector(context);
    };
  }

  /// Initialize editing with optional initial text
  void setupSmartTextController({String? initialText}) {
    _controller.initialize(initialText: initialText);
  }

  /// Start editing mode
  void startEditingMode({String? initialText}) {
    setEditingState(true);
    if (initialText != null) {
      _controller.updateTextSilently(initialText);
    }
    _controller.textInputService.requestFocus();
  }

  /// Set the editing state
  void setEditingState(bool editing) {
    if (mounted) {
      setState(() {
        _isEditing = editing;
      });
    }
  }

  /// Set the creating new item flag
  void setCreatingNewItem(bool creating) {
    _isCreatingNewItem = creating;
  }

  /// Handle focus gained for an item
  void onFocusGained(String itemId) {
    context.read<FocusCubit>().setFocus(itemId);
    setEditingState(true);
  }

  /// Handle focus lost
  void onFocusLost() {
    _debounceTimer?.cancel();

    // Skip regular text change processing if we're creating a new item
    if (!_isCreatingNewItem) {
      onRegularTextChange(_controller.textInputService.text);
    }

    // Don't clear focus if we're creating a new item
    if (!_isCreatingNewItem) {
      context.read<FocusCubit>().clearFocus();
    }

    setEditingState(false);

    // If user is interacting with overlay, delay removal to allow selection
    if (_controller.isInteractingWithOverlay) {
      Timer(const Duration(milliseconds: 100), () {
        if (!_controller.isInteractingWithOverlay) {
          _controller.typeSelectorService.hideTypeSelector();
        }
      });
    } else {
      _controller.typeSelectorService.hideTypeSelector();
    }
  }

  /// Handle regular text changes (non-command text)
  void onRegularTextChange(String text) {
    // Default implementation with debouncing
    debouncedSave(text, const Duration(milliseconds: 500), () {
      saveChanges(text);
    });
  }

  /// Debounced save operation
  void debouncedSave(String content, Duration delay, VoidCallback saveCallback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, saveCallback);
  }

  /// Check if this item should have focus based on FocusCubit state
  bool shouldHaveFocus(String itemId) {
    return context.read<FocusCubit>().isFocused(itemId);
  }

  /// Handle keyboard events
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        if (!isShiftPressed) {
          onEnterPressed(isShiftPressed: false);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controller.textInputService.isEmpty) {
          onBackspacePressed();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (handleArrowUp()) {
          return;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (handleArrowDown()) {
          return;
        }
      }
    }
  }

  /// Handle arrow up key press
  bool handleArrowUp() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = _controller.textInputService.cursorPosition;
    final text = _controller.textInputService.text;

    if (!_isOnFirstLine(text, currentPosition)) {
      return false;
    }

    _isProcessingArrowKey = true;
    _cursorPositionBeforeArrow = currentPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNavigationAfterArrowKey(isUpArrow: true);
    });

    return false;
  }

  /// Handle arrow down key press
  bool handleArrowDown() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = _controller.textInputService.cursorPosition;
    final text = _controller.textInputService.text;

    if (!_isOnLastLine(text, currentPosition)) {
      return false;
    }

    _isProcessingArrowKey = true;
    _cursorPositionBeforeArrow = currentPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNavigationAfterArrowKey(isUpArrow: false);
    });

    return false;
  }

  /// Check if navigation should happen after arrow key was processed
  void _checkForNavigationAfterArrowKey({required bool isUpArrow}) {
    if (!_isProcessingArrowKey) return;

    final cursorPositionAfterArrow = _controller.textInputService.cursorPosition;
    final text = _controller.textInputService.text;

    bool shouldNavigate = false;

    if (_cursorPositionBeforeArrow != null) {
      final cursorDidntMove = cursorPositionAfterArrow == _cursorPositionBeforeArrow;

      if (isUpArrow) {
        final isOnFirstLine = _isOnFirstLine(text, cursorPositionAfterArrow);
        shouldNavigate = cursorDidntMove && isOnFirstLine;
      } else {
        final isOnLastLine = _isOnLastLine(text, cursorPositionAfterArrow);
        shouldNavigate = cursorDidntMove && isOnLastLine;
      }
    }

    if (shouldNavigate) {
      if (isUpArrow) {
        _navigateToPreviousItem();
      } else {
        _navigateToNextItem();
      }
    }

    _isProcessingArrowKey = false;
    _cursorPositionBeforeArrow = null;
  }

  /// Check if cursor is on the first line of text
  bool _isOnFirstLine(String text, int cursorPosition) {
    final renderEditable = _getRenderEditable();
    return _controller.navigationService.isOnFirstLine(text, cursorPosition, renderEditable);
  }

  /// Check if cursor is on the last line of text
  bool _isOnLastLine(String text, int cursorPosition) {
    final renderEditable = _getRenderEditable();
    return _controller.navigationService.isOnLastLine(text, cursorPosition, renderEditable);
  }

  /// Get the RenderEditable from the focus node's context
  RenderEditable? _getRenderEditable() {
    final focusNode = _controller.textInputService.focusNode;
    final renderObject = focusNode.context?.findRenderObject();
    return _controller.navigationService.findRenderEditable(renderObject);
  }

  /// Navigate to the previous item in the timeline
  void _navigateToPreviousItem() {
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final days = currentState.selectedProject != null 
          ? currentState.getDaysForProject(currentState.selectedProject!.id)
          : currentState.days;
      final previousItemId = _controller.navigationService.findPreviousItemId(
        getCurrentItemId(), 
        days,
      );

      if (previousItemId != null) {
        focusCubit.setFocus(previousItemId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.navigationService.positionCursorAtEnd(_controller.textInputService.textController);
        });
      }
    }
  }

  /// Navigate to the next item in the timeline
  void _navigateToNextItem() {
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final days = currentState.selectedProject != null 
          ? currentState.getDaysForProject(currentState.selectedProject!.id)
          : currentState.days;
      final nextItemId = _controller.navigationService.findNextItemId(
        getCurrentItemId(), 
        days,
      );

      if (nextItemId != null) {
        focusCubit.setFocus(nextItemId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.navigationService.positionCursorAtBeginning(_controller.textInputService.textController);
        });
      }
    }
  }

  /// Build editing input widget
  Widget buildEditingInput({
    required BuildContext context, 
    required TextStyle? style, 
    bool autofocus = true,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onFocusLost();
        }
      },
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: handleKeyEvent,
        child: TextFormField(
          controller: _controller.textInputService.textController,
          focusNode: _controller.textInputService.focusNode,
          autofocus: autofocus,
          maxLines: null,
          style: style,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          // onFieldSubmitted: (_) {
          //   onEnterPressed(isShiftPressed: false);
          // },
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

  /// Get current text style for line calculations
  TextStyle getCurrentTextStyle() {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }

  /// Update text silently without triggering command detection
  void updateTextSilently(String text) {
    _controller.updateTextSilently(text);
  }

  /// Get current text from the controller
  String getCurrentText() {
    return _controller.textInputService.text;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // === Abstract methods to be implemented by concrete widgets ===

  /// Get the current item ID - to be implemented by concrete widgets
  String getCurrentItemId();

  /// Transform the current item to a new type with new content
  Future<void> transformCurrentItem({required ItemType newType, required String newContent});

  /// Save changes to the item - to be implemented by concrete widgets
  void saveChanges(String newContent);

  /// Handle Enter key press - can be overridden by concrete widgets
  void onEnterPressed({required bool isShiftPressed}) {
    // Default implementation - can be overridden
  }

  /// Handle Backspace key press when text is empty - can be overridden by concrete widgets
  void onBackspacePressed() {
    // Default implementation - can be overridden
  }
}
