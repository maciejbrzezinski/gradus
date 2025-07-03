import 'package:flutter/material.dart';
import 'package:gradus/domain/entities/item_type.dart';
import '../../../core/utils/text_commands.dart';

mixin SmartTextInputMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController textController;
  late FocusNode focusNode;
  bool _isProcessingCommand = false;
  
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
  }
  
  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  
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
    await transformCurrentItem(
      newType: match.command.targetType,
      newContent: cleanText,
    );
  }
  
  // Method to safely clear slash and transform item
  void clearSlashAndTransform({
    required ItemType newType,
    required String newContent,
  }) async {
    _isProcessingCommand = true;
    
    // Clear the slash immediately
    updateTextSilently(newContent);
    
    // Then transform the item
    await transformCurrentItem(newType: newType, newContent: newContent);
    
    _isProcessingCommand = false;
  }
  
  // Abstract methods to be implemented by concrete widgets
  Future<void> transformCurrentItem({
    required ItemType newType,
    required String newContent,
  });
  
  void onSlashCommand();
  
  void onRegularTextChange(String text) {
    // Default implementation - can be overridden
  }
  
  void onEnterPressed({required bool isShiftPressed}) {
    // Default implementation - can be overridden
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
}
