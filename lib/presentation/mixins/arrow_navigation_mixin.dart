import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/editing/navigation_service.dart';
import '../cubits/focus/focus_cubit.dart';
import '../cubits/timeline/timeline_cubit.dart';
import '../cubits/timeline/timeline_state.dart';

/// Mixin responsible for handling arrow key navigation between timeline items
mixin ArrowNavigationMixin<T extends StatefulWidget> on State<T> {
  final NavigationService _navigationService = GetIt.instance<NavigationService>();
  
  int? _cursorPositionBeforeArrow;
  bool _isProcessingArrowKey = false;

  /// Handle arrow up key press
  /// Returns true if navigation was handled, false if default behavior should continue
  bool handleArrowUp() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = getCurrentCursorPosition();
    final text = getCurrentText();

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
  bool handleArrowDown() {
    if (_isProcessingArrowKey) return false;

    final currentPosition = getCurrentCursorPosition();
    final text = getCurrentText();

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

    final cursorPositionAfterArrow = getCurrentCursorPosition();
    final text = getCurrentText();

    // Check if cursor position didn't change (meaning we hit a boundary)
    bool shouldNavigate = false;

    if (_cursorPositionBeforeArrow != null) {
      final cursorDidntMove = cursorPositionAfterArrow == _cursorPositionBeforeArrow;

      if (isUpArrow) {
        final isOnFirstLine = _isOnFirstLine(text, cursorPositionAfterArrow);
        // If cursor didn't move up and we're on first line, navigate to previous item
        shouldNavigate = cursorDidntMove && isOnFirstLine;
      } else {
        final isOnLastLine = _isOnLastLine(text, cursorPositionAfterArrow);
        // If cursor didn't move down and we're on last line, navigate to next item
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

    // Reset state
    _isProcessingArrowKey = false;
    _cursorPositionBeforeArrow = null;
  }

  /// Check if cursor is on the first line of text
  bool _isOnFirstLine(String text, int cursorPosition) {
    final renderEditable = _getRenderEditable();
    return _navigationService.isOnFirstLine(text, cursorPosition, renderEditable);
  }

  /// Check if cursor is on the last line of text
  bool _isOnLastLine(String text, int cursorPosition) {
    final renderEditable = _getRenderEditable();
    return _navigationService.isOnLastLine(text, cursorPosition, renderEditable);
  }

  /// Get the RenderEditable from the focus node's context
  RenderEditable? _getRenderEditable() {
    final focusNode = getFocusNode();
    final renderObject = focusNode?.context?.findRenderObject();
    return _navigationService.findRenderEditable(renderObject);
  }

  /// Navigate to the previous item in the timeline
  void _navigateToPreviousItem() {
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final previousItemId = _navigationService.findPreviousItemId(
        getCurrentItemId(), 
        currentState.effectiveDays,
      );

      if (previousItemId != null) {
        focusCubit.setFocus(previousItemId);
        // Schedule cursor positioning after the widget rebuilds and focuses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _positionCursorAtEnd();
        });
      }
    }
  }

  /// Navigate to the next item in the timeline
  void _navigateToNextItem() {
    final currentState = context.read<TimelineCubit>().state;
    if (currentState is TimelineLoaded) {
      final focusCubit = context.read<FocusCubit>();
      final nextItemId = _navigationService.findNextItemId(
        getCurrentItemId(), 
        currentState.effectiveDays,
      );

      if (nextItemId != null) {
        focusCubit.setFocus(nextItemId);
        // Schedule cursor positioning after the widget rebuilds and focuses
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _positionCursorAtBeginning();
        });
      }
    }
  }

  /// Position cursor at the end of the text
  void _positionCursorAtEnd() {
    final textController = getTextController();
    if (textController != null) {
      _navigationService.positionCursorAtEnd(textController);
    }
  }

  /// Position cursor at the beginning of the text
  void _positionCursorAtBeginning() {
    final textController = getTextController();
    if (textController != null) {
      _navigationService.positionCursorAtBeginning(textController);
    }
  }

  // Abstract methods to be implemented by concrete widgets
  
  /// Get the current item ID
  String getCurrentItemId();

  /// Get the current cursor position
  int getCurrentCursorPosition();

  /// Get the current text
  String getCurrentText();

  /// Get the text controller
  TextEditingController? getTextController();

  /// Get the focus node
  FocusNode? getFocusNode();
}
