import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/focus/focus_cubit.dart';

/// Mixin responsible for managing editing state and focus
mixin EditingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isEditing = false;
  Timer? _debounceTimer;
  bool _isCreatingNewItem = false;

  bool get isEditing => _isEditing;
  bool get isCreatingNewItem => _isCreatingNewItem;

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

  /// Start editing with optional initial text
  void startEditing({String? initialText}) {
    setEditingState(true);
  }

  /// Handle focus gained for an item
  void onFocusGained(String itemId) {
    context.read<FocusCubit>().setFocus(itemId);
    setEditingState(true);
  }

  /// Handle focus lost
  void onFocusLost() {
    _debounceTimer?.cancel();

    // Don't clear focus if we're creating a new item
    if (!_isCreatingNewItem) {
      context.read<FocusCubit>().clearFocus();
    }

    setEditingState(false);
  }

  /// Check if this item should have focus based on FocusCubit state
  bool shouldHaveFocus(String itemId) {
    return context.read<FocusCubit>().isFocused(itemId);
  }

  /// Debounced save operation
  void debouncedSave(String content, Duration delay, VoidCallback saveCallback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, saveCallback);
  }

  /// Dispose of resources
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
