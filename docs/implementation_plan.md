# Gradus Implementation Plan

This document outlines the implementation plan for the Gradus application, focusing on the core data models, widgets, and their relationships.

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # Main application widget
├── models/                   # Data models
│   ├── block.dart            # Base block model
│   ├── block_types/          # Specific block type models
│   │   ├── text_block.dart
│   │   ├── list_block.dart
│   │   ├── todo_block.dart
│   │   ├── toggle_block.dart
│   │   ├── divider_block.dart
│   │   ├── header_block.dart
│   │   ├── image_block.dart
│   │   └── file_block.dart
│   ├── document.dart         # Document model
│   ├── repetition_rule.dart  # Task repetition rules
│   └── user.dart             # User model
├── widgets/                  # UI components
│   ├── blocks/               # Block-specific widgets
│   │   ├── block_widget.dart # Base block widget
│   │   ├── text_block.dart
│   │   ├── list_block.dart
│   │   ├── todo_block.dart
│   │   ├── toggle_block.dart
│   │   ├── divider_block.dart
│   │   ├── header_block.dart
│   │   ├── image_block.dart
│   │   └── file_block.dart
│   ├── command_palette.dart  # Command palette widget
│   ├── document_view.dart    # Main document view
│   └── format_toolbar.dart   # Text formatting toolbar
├── controllers/              # Logic controllers
│   ├── block_controller.dart # Controls block behavior
│   ├── document_controller.dart # Manages document state
│   └── task_scheduler.dart   # Handles repetitive tasks
├── services/                 # Backend services
│   ├── storage_service.dart  # Local storage
│   ├── sync_service.dart     # Cloud synchronization
│   └── auth_service.dart     # Authentication
├── utils/                    # Utility functions
│   ├── block_converter.dart  # Converts between block types
│   ├── date_utils.dart       # Date manipulation utilities
│   └── id_generator.dart     # Generates unique IDs
└── screens/                  # Application screens
    ├── home_screen.dart      # Main home screen
    ├── document_screen.dart  # Document editing screen
    ├── settings_screen.dart  # Application settings
    └── profile_screen.dart   # User profile
```

## Core Data Models

### Block Model

```dart
// lib/models/block.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum BlockType {
  text,
  list,
  todo,
  toggle,
  divider,
  header,
  image,
  file,
}

abstract class Block {
  final String id;
  final BlockType type;
  dynamic content;
  Map<String, dynamic> metadata;
  List<Block> children;
  
  Block({
    String? id,
    required this.type,
    this.content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) : 
    id = id ?? const Uuid().v4(),
    metadata = metadata ?? {},
    children = children ?? [];
    
  // Factory method to create blocks of specific types
  factory Block.create(BlockType type, {
    String? id,
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) {
    switch (type) {
      case BlockType.text:
        return TextBlock(
          id: id,
          content: content ?? '',
          metadata: metadata,
          children: children,
        );
      case BlockType.list:
        return ListBlock(
          id: id,
          content: content ?? '',
          metadata: metadata,
          children: children,
        );
      // Add cases for other block types
      default:
        throw ArgumentError('Unsupported block type: $type');
    }
  }
  
  // Convert block to JSON for storage
  Map<String, dynamic> toJson();
  
  // Create a copy of the block with updated properties
  Block copyWith({
    String? id,
    BlockType? type,
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  });
}
```

### Text Block Model

```dart
// lib/models/block_types/text_block.dart
import '../block.dart';

class TextFormatting {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final String? color;
  final String? backgroundColor;
  final String? fontFamily;
  final double? fontSize;
  
  TextFormatting({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.color,
    this.backgroundColor,
    this.fontFamily,
    this.fontSize,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'strikethrough': strikethrough,
      'color': color,
      'backgroundColor': backgroundColor,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }
  
  factory TextFormatting.fromJson(Map<String, dynamic> json) {
    return TextFormatting(
      bold: json['bold'] ?? false,
      italic: json['italic'] ?? false,
      underline: json['underline'] ?? false,
      strikethrough: json['strikethrough'] ?? false,
      color: json['color'],
      backgroundColor: json['backgroundColor'],
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize'],
    );
  }
}

class TextBlock extends Block {
  String get textContent => content as String;
  set textContent(String value) => content = value;
  
  TextFormatting get formatting => 
    TextFormatting.fromJson(metadata['formatting'] ?? {});
  set formatting(TextFormatting value) => 
    metadata['formatting'] = value.toJson();
  
  TextBlock({
    String? id,
    String content = '',
    Map<String, dynamic>? metadata,
    List<Block>? children,
    TextFormatting? formatting,
  }) : super(
    id: id,
    type: BlockType.text,
    content: content,
    metadata: metadata ?? {},
    children: children,
  ) {
    if (formatting != null) {
      this.formatting = formatting;
    }
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'metadata': metadata,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
  
  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      id: json['id'],
      content: json['content'] ?? '',
      metadata: json['metadata'] ?? {},
      children: (json['children'] as List?)
          ?.map((child) => Block.create(
                BlockType.values.firstWhere(
                  (type) => type.toString().split('.').last == child['type'],
                ),
                id: child['id'],
                content: child['content'],
                metadata: child['metadata'],
              ))
          .toList() ?? [],
    );
  }
  
  @override
  Block copyWith({
    String? id,
    BlockType? type,
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) {
    return TextBlock(
      id: id ?? this.id,
      content: content ?? this.content,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      children: children ?? List<Block>.from(this.children),
    );
  }
}
```

### Todo Block Model

```dart
// lib/models/block_types/todo_block.dart
import '../block.dart';
import '../repetition_rule.dart';

class TodoBlock extends Block {
  String get textContent => content as String;
  set textContent(String value) => content = value;
  
  bool get completed => metadata['completed'] ?? false;
  set completed(bool value) => metadata['completed'] = value;
  
  DateTime? get dueDate => 
    metadata['dueDate'] != null ? DateTime.parse(metadata['dueDate']) : null;
  set dueDate(DateTime? value) => 
    metadata['dueDate'] = value?.toIso8601String();
  
  RepetitionRule? get repetition => 
    metadata['repetition'] != null 
      ? RepetitionRule.fromJson(metadata['repetition']) 
      : null;
  set repetition(RepetitionRule? value) => 
    metadata['repetition'] = value?.toJson();
  
  TodoBlock({
    String? id,
    String content = '',
    Map<String, dynamic>? metadata,
    List<Block>? children,
    bool completed = false,
    DateTime? dueDate,
    RepetitionRule? repetition,
  }) : super(
    id: id,
    type: BlockType.todo,
    content: content,
    metadata: metadata ?? {},
    children: children,
  ) {
    this.completed = completed;
    if (dueDate != null) this.dueDate = dueDate;
    if (repetition != null) this.repetition = repetition;
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'metadata': metadata,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
  
  factory TodoBlock.fromJson(Map<String, dynamic> json) {
    return TodoBlock(
      id: json['id'],
      content: json['content'] ?? '',
      metadata: json['metadata'] ?? {},
      children: (json['children'] as List?)
          ?.map((child) => Block.create(
                BlockType.values.firstWhere(
                  (type) => type.toString().split('.').last == child['type'],
                ),
                id: child['id'],
                content: child['content'],
                metadata: child['metadata'],
              ))
          .toList() ?? [],
    );
  }
  
  @override
  Block copyWith({
    String? id,
    BlockType? type,
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) {
    return TodoBlock(
      id: id ?? this.id,
      content: content ?? this.content,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      children: children ?? List<Block>.from(this.children),
    );
  }
}
```

### Repetition Rule Model

```dart
// lib/models/repetition_rule.dart

enum RepetitionType {
  daily,
  weekly,
  monthly,
  custom,
}

class RepetitionRule {
  final RepetitionType type;
  final int interval;
  final List<int> daysOfWeek;
  final int dayOfMonth;
  final DateTime? endDate;
  final int? maxOccurrences;
  
  RepetitionRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    this.endDate,
    this.maxOccurrences,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.toIso8601String(),
      'maxOccurrences': maxOccurrences,
    };
  }
  
  factory RepetitionRule.fromJson(Map<String, dynamic> json) {
    return RepetitionRule(
      type: RepetitionType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List?)?.cast<int>() ?? [],
      dayOfMonth: json['dayOfMonth'] ?? 1,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      maxOccurrences: json['maxOccurrences'],
    );
  }
  
  // Factory methods for common repetition patterns
  factory RepetitionRule.daily({int interval = 1}) {
    return RepetitionRule(
      type: RepetitionType.daily,
      interval: interval,
    );
  }
  
  factory RepetitionRule.weekly({
    int interval = 1,
    required List<int> daysOfWeek,
  }) {
    return RepetitionRule(
      type: RepetitionType.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
    );
  }
  
  factory RepetitionRule.monthly({
    int interval = 1,
    required int dayOfMonth,
  }) {
    return RepetitionRule(
      type: RepetitionType.monthly,
      interval: interval,
      dayOfMonth: dayOfMonth,
    );
  }
}
```

### Document Model

```dart
// lib/models/document.dart
import 'block.dart';

class Document {
  final String id;
  String title;
  List<Block> blocks;
  DateTime createdAt;
  DateTime updatedAt;
  
  Document({
    String? id,
    this.title = 'Untitled',
    List<Block>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    blocks = blocks ?? [Block.create(BlockType.text)],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      blocks: (json['blocks'] as List?)
          ?.map((blockJson) => Block.create(
                BlockType.values.firstWhere(
                  (type) => type.toString().split('.').last == blockJson['type'],
                ),
                id: blockJson['id'],
                content: blockJson['content'],
                metadata: blockJson['metadata'],
                children: (blockJson['children'] as List?)
                    ?.map((childJson) => Block.create(
                          BlockType.values.firstWhere(
                            (type) => type.toString().split('.').last == childJson['type'],
                          ),
                          id: childJson['id'],
                          content: childJson['content'],
                          metadata: childJson['metadata'],
                        ))
                    .toList(),
              ))
          .toList() ?? [Block.create(BlockType.text)],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
  
  void addBlock(Block block, {int? index}) {
    if (index != null) {
      blocks.insert(index, block);
    } else {
      blocks.add(block);
    }
    updatedAt = DateTime.now();
  }
  
  void removeBlock(String blockId) {
    blocks.removeWhere((block) => block.id == blockId);
    updatedAt = DateTime.now();
  }
  
  void updateBlock(String blockId, Block updatedBlock) {
    final index = blocks.indexWhere((block) => block.id == blockId);
    if (index != -1) {
      blocks[index] = updatedBlock;
      updatedAt = DateTime.now();
    }
  }
  
  void reorderBlocks(String blockId, int newIndex) {
    final block = blocks.firstWhere((block) => block.id == blockId);
    final oldIndex = blocks.indexWhere((block) => block.id == blockId);
    blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);
    updatedAt = DateTime.now();
  }
}
```

## Core Widgets

### Block Widget Base Class

```dart
// lib/widgets/blocks/block_widget.dart
import 'package:flutter/material.dart';
import '../../models/block.dart';
import '../../controllers/block_controller.dart';

abstract class BlockWidget extends StatefulWidget {
  final Block block;
  final BlockController controller;
  final FocusNode focusNode;
  final bool isSelected;
  final VoidCallback? onFocusChange;
  
  const BlockWidget({
    Key? key,
    required this.block,
    required this.controller,
    required this.focusNode,
    this.isSelected = false,
    this.onFocusChange,
  }) : super(key: key);
  
  @override
  BlockWidgetState createState();
}

abstract class BlockWidgetState<T extends BlockWidget> extends State<T> {
  late TextEditingController textController;
  
  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: getBlockContent());
    textController.addListener(_onTextChanged);
    
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus && widget.onFocusChange != null) {
        widget.onFocusChange!();
      }
    });
  }
  
  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    updateBlockContent(textController.text);
    
    // Check for '/' command
    if (textController.text.endsWith('/')) {
      widget.controller.showCommandPalette();
    }
    
    // Check for empty content with backspace
    if (textController.text.isEmpty && widget.controller.isBackspacePressed) {
      widget.controller.deleteBlock(widget.block.id);
    }
  }
  
  String getBlockContent();
  
  void updateBlockContent(String content);
  
  @override
  Widget build(BuildContext context);
}
```

### Text Block Widget

```dart
// lib/widgets/blocks/text_block.dart
import 'package:flutter/material.dart';
import '../../models/block.dart';
import '../../models/block_types/text_block.dart';
import 'block_widget.dart';

class TextBlockWidget extends BlockWidget {
  const TextBlockWidget({
    Key? key,
    required Block block,
    required BlockController controller,
    required FocusNode focusNode,
    bool isSelected = false,
    VoidCallback? onFocusChange,
  }) : super(
    key: key,
    block: block,
    controller: controller,
    focusNode: focusNode,
    isSelected: isSelected,
    onFocusChange: onFocusChange,
  );
  
  @override
  TextBlockWidgetState createState() => TextBlockWidgetState();
}

class TextBlockWidgetState extends BlockWidgetState<TextBlockWidget> {
  TextBlock get textBlock => widget.block as TextBlock;
  
  @override
  String getBlockContent() {
    return textBlock.textContent;
  }
  
  @override
  void updateBlockContent(String content) {
    widget.controller.updateBlockContent(widget.block.id, content);
  }
  
  @override
  Widget build(BuildContext context) {
    final formatting = textBlock.formatting;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: textController,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontWeight: formatting.bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: formatting.italic ? FontStyle.italic : FontStyle.normal,
          decoration: formatting.underline
              ? TextDecoration.underline
              : formatting.strikethrough
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
          color: formatting.color != null ? Color(int.parse(formatting.color!)) : null,
          backgroundColor: formatting.backgroundColor != null
              ? Color(int.parse(formatting.backgroundColor!))
              : null,
          fontFamily: formatting.fontFamily,
          fontSize: formatting.fontSize,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
```

### Todo Block Widget

```dart
// lib/widgets/blocks/todo_block.dart
import 'package:flutter/material.dart';
import '../../models/block.dart';
import '../../models/block_types/todo_block.dart';
import 'block_widget.dart';

class TodoBlockWidget extends BlockWidget {
  const TodoBlockWidget({
    Key? key,
    required Block block,
    required BlockController controller,
    required FocusNode focusNode,
    bool isSelected = false,
    VoidCallback? onFocusChange,
  }) : super(
    key: key,
    block: block,
    controller: controller,
    focusNode: focusNode,
    isSelected: isSelected,
    onFocusChange: onFocusChange,
  );
  
  @override
  TodoBlockWidgetState createState() => TodoBlockWidgetState();
}

class TodoBlockWidgetState extends BlockWidgetState<TodoBlockWidget> {
  TodoBlock get todoBlock => widget.block as TodoBlock;
  
  @override
  String getBlockContent() {
    return todoBlock.textContent;
  }
  
  @override
  void updateBlockContent(String content) {
    widget.controller.updateBlockContent(widget.block.id, content);
  }
  
  void _toggleCompleted() {
    widget.controller.updateTodoStatus(
      widget.block.id,
      !todoBlock.completed,
    );
  }
  
  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: todoBlock.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      widget.controller.updateTodoDueDate(widget.block.id, date);
    }
  }
  
  void _showRepetitionDialog() {
    // Show dialog to configure repetition
    // Implementation details omitted for brevity
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: todoBlock.completed,
            onChanged: (_) => _toggleCompleted(),
          ),
          
          // Content
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                decoration: todoBlock.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todoBlock.completed
                    ? Colors.grey
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          // Due date button
          if (todoBlock.dueDate != null || widget.isSelected)
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: todoBlock.dueDate != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                size: 20,
              ),
              onPressed: _showDatePicker,
            ),
          
          // Repetition button
          if (todoBlock.repetition != null || widget.isSelected)
            IconButton(
              icon: Icon(
                Icons.repeat,
                color: todoBlock.repetition != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                size: 20,
              ),
              onPressed: _showRepetitionDialog,
            ),
        ],
      ),
    );
  }
}
```

### Command Palette Widget

```dart
// lib/widgets/command_palette.dart
import 'package:flutter/material.dart';
import '../models/block.dart';

class BlockTypeOption {
  final BlockType type;
  final String title;
  final IconData icon;
  final String description;
  
  const BlockTypeOption({
    required this.type,
    required this.title,
    required this.icon,
    this.description = '',
  });
}

class CommandPalette extends StatefulWidget {
  final TextEditingController textController;
  final Function(BlockType) onBlockTypeSelected;
  final Offset position;
  
  const CommandPalette({
    Key? key,
    required this.textController,
    required this.onBlockTypeSelected,
    required this.position,
  }) : super(key: key);
  
  @override
  _CommandPaletteState createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  String _searchQuery = '';
  List<BlockTypeOption> _filteredOptions = [];
  int _selectedIndex = 0;
  
  final List<BlockTypeOption> _allOptions = [
    BlockTypeOption(
      type: BlockType.text,
      title: 'Text',
      icon: Icons.text_fields,
      description: 'Just start writing with plain text.',
    ),
    BlockTypeOption(
      type: BlockType.list,
      title: 'List',
      icon: Icons.list,
      description: 'Create a simple bulleted list.',
    ),
    BlockTypeOption(
      type: BlockType.todo,
      title: 'To-do',
      icon: Icons.check_box_outline_blank,
      description: 'Track tasks with a to-do list.',
    ),
    BlockTypeOption(
      type: BlockType.toggle,
      title: 'Toggle',
      icon: Icons.arrow_drop_down_circle_outlined,
      description: 'Collapsible content that can be expanded.',
    ),
    BlockTypeOption(
      type: BlockType.divider,
      title: 'Divider',
      icon: Icons.horizontal_rule,
      description: 'Add a visual divider.',
    ),
    BlockTypeOption(
      type: BlockType.header,
      title: 'Heading',
      icon: Icons.title,
      description: 'Large section heading.',
    ),
    BlockTypeOption(
      type: BlockType.image,
      title: 'Image',
      icon: Icons.image,
      description: 'Upload or embed an image.',
    ),
    BlockTypeOption(
      type: BlockType.file,
      title: 'File',
      icon: Icons.attach_file,
      description: 'Upload or embed a file.',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _filteredOptions = _allOptions;
    
    // Listen for changes in the text field
    widget.textController.addListener(_onTextChanged);
    
    // Listen for keyboard events
    FocusScope.of(context).addListener(_handleKeyboard);
  }
  
  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    FocusScope.of(context).removeListener(_handleKeyboard);
    super.dispose();
  }
  
  void _onTextChanged() {
    // Extract search query (everything after the '/')
    final text = widget.textController.text;
    final slashIndex = text.lastIndexOf('/');
    if (slashIndex >= 0) {
      _searchQuery = text.substring(slashIndex + 1);
      _filterOptions();
    }
  }
  
  void _filterOptions() {
    setState(() {
      _filteredOptions = _allOptions
          .where((option) => 
              option.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              option.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      _selectedIndex = 0;
    });
  }
  
  void _handleKeyboard() {
    // Handle keyboard navigation
    final focusNode = FocusScope.of(context);
    
    if (focusNode.hasPrimaryFocus) {
      // Handle arrow keys
      if (focusNode.hasFocus) {
        // Implementation details omitted for brevity
      }
    }
  }
  
  void _selectOption(int index) {
    if (index >= 0 && index < _filteredOptions.length) {
      final option = _filteredOptions[index];
      widget.onBlockTypeSelected(option.type);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      width: 300,
      child: Card(
        elevation: 8,
        child: Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add block',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filteredOptions[index];
                    final isSelected = index == _selectedIndex;
                    
                    return ListTile(
                      leading: Icon(option.icon),
                      title: Text(option.title),
                      subtitle: Text(
                        option.description,
                        style: TextStyle(fontSize: 12),
                      ),
