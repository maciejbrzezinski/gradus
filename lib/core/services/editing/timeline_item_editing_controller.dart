import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../presentation/widgets/timeline/item_type_selector_modal.dart';
import '../../utils/text_commands.dart';
import 'text_input_service.dart';
import 'type_selector_service.dart';
import 'navigation_service.dart';

/// Main controller that coordinates all editing services
@injectable
class TimelineItemEditingController {
  final TextInputService _textInputService;
  final TypeSelectorService _typeSelectorService;
  final NavigationService _navigationService;

  // Callbacks
  Function(String)? onTextChanged;
  Function({required ItemType newType, required String newContent})? onTransformItem;
  VoidCallback? onSlashCommand;

  TimelineItemEditingController(
    this._textInputService,
    this._typeSelectorService,
    this._navigationService,
  );

  /// Initialize the controller with optional initial text
  void initialize({String? initialText}) {
    _textInputService.initialize(initialText: initialText);
    _setupCallbacks();
  }

  /// Setup callbacks between services
  void _setupCallbacks() {
    _textInputService.onTextChanged = (text) {
      onTextChanged?.call(text);
    };

    _textInputService.onCommandDetected = (commandMatch) {
      _handleCommand(commandMatch);
    };

    _textInputService.onSlashCommand = () {
      onSlashCommand?.call();
    };
  }

  /// Handle detected command
  void _handleCommand(CommandMatch commandMatch) {
    final cleanText = commandMatch.remainingText.trim();
    onTransformItem?.call(
      newType: commandMatch.command.targetType,
      newContent: cleanText,
    );
  }

  /// Show type selector overlay
  void showTypeSelector(BuildContext context) {
    _typeSelectorService.showTypeSelector(
      context: context,
      onTypeSelected: (option) {
        _handleTypeSelection(option);
      },
      onDismiss: () {
        _textInputService.requestFocus();
      },
    );
  }

  /// Handle type selection from overlay
  void _handleTypeSelection(ItemTypeOption option) {
    final itemType = _typeSelectorService.itemTypeOptionToItemType(option);
    onTransformItem?.call(
      newType: itemType,
      newContent: '',
    );
  }

  /// Clear slash and transform item
  void clearSlashAndTransform({
    required ItemType newType,
    required String newContent,
  }) {
    _textInputService.updateTextSilently(newContent);
    onTransformItem?.call(newType: newType, newContent: newContent);
  }

  /// Update text without triggering command detection
  void updateTextSilently(String text) {
    _textInputService.updateTextSilently(text);
  }

  /// Get text input service for direct access
  TextInputService get textInputService => _textInputService;

  /// Get type selector service for direct access
  TypeSelectorService get typeSelectorService => _typeSelectorService;

  /// Get navigation service for direct access
  NavigationService get navigationService => _navigationService;

  /// Check if currently interacting with overlay
  bool get isInteractingWithOverlay => _typeSelectorService.isInteractingWithOverlay;

  /// Dispose of resources
  void dispose() {
    _textInputService.dispose();
    _typeSelectorService.dispose();
  }
}
