# Gradus Implementation Plan

This document outlines the implementation plan for the Gradus application, focusing on the core data models, widgets, and their relationships.

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # Main application widget
├── models/                   # Data models
│   ├── block.dart            # Base block model
│   ├── text_formatting.dart  # Text formatting options
│   ├── block_types/          # Specific block type models
│   │   ├── formatted_span.dart # Text span with formatting
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

### Text Formatting

```dart
// lib/models/text_formatting.dart
import 'package:flutter/material.dart';

/// Represents text formatting options
class TextFormatting {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final String? color;
  final String? backgroundColor;
  final String? fontFamily;
  final double? fontSize;
  
  const TextFormatting({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.color,
    this.backgroundColor,
    this.fontFamily,
    this.fontSize,
  });
  
  /// Default formatting with no special styles
  static const TextFormatting defaultFormatting = TextFormatting();
  
  /// Bold formatting
  static const TextFormatting boldFormatting = TextFormatting(bold: true);
  
  /// Italic formatting
  static const TextFormatting italicFormatting = TextFormatting(italic: true);
  
  /// Underline formatting
  static const TextFormatting underlineFormatting = TextFormatting(underline: true);
  
  /// Strikethrough formatting
  static const TextFormatting strikethroughFormatting = TextFormatting(strikethrough: true);
  
  /// Create formatting from JSON
  factory TextFormatting.fromJson(Map<String, dynamic> json) {
    return TextFormatting(
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      color: json['color'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      fontFamily: json['fontFamily'] as String?,
      fontSize: json['fontSize'] as double?,
    );
  }
  
  /// Convert formatting to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'bold': bold,
      'italic': italic,
      'underline': underline,
      'strikethrough': strikethrough,
      if (color != null) 'color': color,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
    };
  }
  
  /// Create a copy of this formatting with updated properties
  TextFormatting copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    String? color,
    String? backgroundColor,
    String? fontFamily,
    double? fontSize,
  }) {
    return TextFormatting(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }
  
  /// Merge this formatting with another formatting
  TextFormatting merge(TextFormatting other) {
    return TextFormatting(
      bold: other.bold || bold,
      italic: other.italic || italic,
      underline: other.underline || underline,
      strikethrough: other.strikethrough || strikethrough,
      color: other.color ?? color,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontFamily: other.fontFamily ?? fontFamily,
      fontSize: other.fontSize ?? fontSize,
    );
  }
  
  /// Toggle a specific formatting attribute
  TextFormatting toggle(String attribute) {
    switch (attribute) {
      case 'bold':
        return copyWith(bold: !bold);
      case 'italic':
        return copyWith(italic: !italic);
      case 'underline':
        return copyWith(underline: !underline);
      case 'strikethrough':
        return copyWith(strikethrough: !strikethrough);
      default:
        return this;
    }
  }
  
  /// Convert to TextStyle for rendering
  TextStyle toTextStyle() {
    return TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: _getTextDecoration(),
      decorationColor: color != null ? Color(int.parse(color!)) : null,
      color: color != null ? Color(int.parse(color!)) : null,
      backgroundColor: backgroundColor != null ? Color(int.parse(backgroundColor!)) : null,
      fontFamily: fontFamily,
      fontSize: fontSize,
    );
  }
  
  /// Get the text decoration based on formatting
  TextDecoration _getTextDecoration() {
    if (underline && strikethrough) {
      return TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    } else if (underline) {
      return TextDecoration.underline;
    } else if (strikethrough) {
      return TextDecoration.lineThrough;
    } else {
      return TextDecoration.none;
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextFormatting &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.color == color &&
        other.backgroundColor == backgroundColor &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize;
  }
  
  @override
  int get hashCode =>
      bold.hashCode ^
      italic.hashCode ^
      underline.hashCode ^
      strikethrough.hashCode ^
      color.hashCode ^
      backgroundColor.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode;
  
  @override
  String toString() {
    return 'TextFormatting(bold: $bold, italic: $italic, underline: $underline, strikethrough: $strikethrough)';
  }
}
```

### Formatted Span

```dart
// lib/models/block_types/formatted_span.dart
import 'package:flutter/foundation.dart';
import '../text_formatting.dart';

/// Represents a span of text with specific formatting
class FormattedSpan {
  /// Starting index in the text (inclusive)
  final int start;
  
  /// Ending index in the text (exclusive)
  final int end;
  
  /// Formatting to apply to this span
  final TextFormatting formatting;
  
  FormattedSpan({
    required this.start,
    required this.end,
    required this.formatting,
  }) : assert(start >= 0 && end >= start, 'Invalid span range');
  
  /// Create a span from JSON
  factory FormattedSpan.fromJson(Map<String, dynamic> json) {
    return FormattedSpan(
      start: json['start'] as int,
      end: json['end'] as int,
      formatting: TextFormatting.fromJson(json['formatting'] as Map<String, dynamic>),
    );
  }
  
  /// Convert span to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'formatting': formatting.toJson(),
    };
  }
  
  /// Create a copy of this span with updated properties
  FormattedSpan copyWith({
    int? start,
    int? end,
    TextFormatting? formatting,
  }) {
    return FormattedSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      formatting: formatting ?? this.formatting,
    );
  }
  
  /// Check if this span overlaps with another span
  bool overlaps(FormattedSpan other) {
    return (start < other.end && end > other.start);
  }
  
  /// Check if this span contains a position
  bool containsPosition(int position) {
    return position >= start && position < end;
  }
  
  /// Check if this span contains a range
  bool containsRange(int rangeStart, int rangeEnd) {
    return start <= rangeStart && end >= rangeEnd;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormattedSpan &&
        other.start == start &&
        other.end == end &&
        other.formatting == formatting;
  }
  
  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ formatting.hashCode;
  
  @override
  String toString() => 'FormattedSpan(start: $start, end: $end, formatting: $formatting)';
}
```

### Text Block Model

```dart
// lib/models/block_types/text_block.dart
import '../block.dart';
import '../text_formatting.dart';
import 'formatted_span.dart';

class TextBlock extends Block {
  String get textContent => content as String;
  set textContent(String value) => content = value;
  
  /// Default formatting for the entire block
  TextFormatting get defaultFormatting => 
    TextFormatting.fromJson(metadata['defaultFormatting'] ?? {});
  set defaultFormatting(TextFormatting value) => 
    metadata['defaultFormatting'] = value.toJson();
  
  /// List of formatted spans for partial text formatting
  List<FormattedSpan> get formattedSpans => 
    (metadata['formattedSpans'] as List?)
        ?.map((span) => FormattedSpan.fromJson(span))
        .toList() ?? [];
  set formattedSpans(List<FormattedSpan> spans) => 
    metadata['formattedSpans'] = spans.map((span) => span.toJson()).toList();
  
  /// Legacy getter for backward compatibility
  TextFormatting get formatting => defaultFormatting;
  set formatting(TextFormatting value) => defaultFormatting = value;
  
  TextBlock({
    String? id,
    String content = '',
    Map<String, dynamic>? metadata,
    List<Block>? children,
    TextFormatting? defaultFormatting,
    List<FormattedSpan>? formattedSpans,
  }) : super(
    id: id,
    type: BlockType.text,
    content: content,
    metadata: metadata ?? {},
    children: children,
  ) {
    if (defaultFormatting != null) {
      this.defaultFormatting = defaultFormatting;
    }
    if (formattedSpans != null) {
      this.formattedSpans = formattedSpans;
    }
  }
  
  /// Apply formatting to a specific range of text
  void applyFormatting(int start, int end, TextFormatting formatting) {
    if (start < 0 || end > textContent.length || start >= end) {
      return;
    }
    
    final newSpan = FormattedSpan(
      start: start,
      end: end,
      formatting: formatting,
    );
    
    final spans = formattedSpans;
    
    // Remove or split existing spans that overlap with the new span
    final updatedSpans = <FormattedSpan>[];
    
    for (final span in spans) {
      if (!span.overlaps(newSpan)) {
        // No overlap, keep the span as is
        updatedSpans.add(span);
      } else {
        // Handle overlap by splitting or trimming the existing span
        if (span.start < newSpan.start) {
          // Add the part before the new span
          updatedSpans.add(FormattedSpan(
            start: span.start,
            end: newSpan.start,
            formatting: span.formatting,
          ));
        }
        
        if (span.end > newSpan.end) {
          // Add the part after the new span
          updatedSpans.add(FormattedSpan(
            start: newSpan.end,
            end: span.end,
            formatting: span.formatting,
          ));
        }
      }
    }
    
    // Add the new span
    updatedSpans.add(newSpan);
    
    // Sort spans by start position
    updatedSpans.sort((a, b) => a.start.compareTo(b.start));
    
    // Update the spans
    formattedSpans = updatedSpans;
  }
  
  /// Get the formatting at a specific position in the text
  TextFormatting getFormattingAt(int position) {
    if (position < 0 || position >= textContent.length) {
      return defaultFormatting;
    }
    
    // Find all spans that contain the position
    final spans = formattedSpans.where((span) => span.containsPosition(position)).toList();
    
    if (spans.isEmpty) {
      return defaultFormatting;
    }
    
    // Merge all applicable formatting
    var result = defaultFormatting;
    for (final span in spans) {
      result = result.merge(span.formatting);
    }
    
    return result;
  }
  
  /// Convert the text content with spans to a list of TextSpans for rendering
  List<InlineSpan> buildTextSpans() {
    final text = textContent;
    final spans = formattedSpans;
    
    if (spans.isEmpty) {
      // If no spans, return the entire text with default formatting
      return [
        TextSpan(
          text: text,
          style: defaultFormatting.toTextStyle(),
        ),
      ];
    }
    
    // Sort spans by start position
    final sortedSpans = List<FormattedSpan>.from(spans)..sort((a, b) => a.start.compareTo(b.start));
    
    final result = <InlineSpan>[];
    int currentIndex = 0;
    
    // Process each span
    for (final span in sortedSpans) {
      // Add text before the span with default formatting
      if (span.start > currentIndex) {
        result.add(
          TextSpan(
            text: text.substring(currentIndex, span.start),
            style: defaultFormatting.toTextStyle(),
          ),
        );
      }
      
      // Add the span text with its formatting
      if (span.end > span.start) {
        result.add(
          TextSpan(
            text: text.substring(span.start, span.end),
            style: span.formatting.toTextStyle(),
          ),
        );
      }
      
      currentIndex = span.end;
    }
    
    // Add any remaining text with default formatting
    if (currentIndex < text.length) {
      result.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: defaultFormatting.toTextStyle(),
        ),
      );
    }
    
    return result;
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
  TextSelection _selection = const TextSelection.collapsed(offset: 0);
  
  @override
  String getBlockContent() {
    return textBlock.textContent;
  }
  
  @override
  void updateBlockContent(String content) {
    widget.controller.updateBlockContent(widget.block.id, content);
  }
  
  /// Update the text selection
  void _updateSelection(TextSelection selection) {
    setState(() {
      _selection = selection;
    });
    
    // Show formatting toolbar if text is selected
    if (!selection.isCollapsed) {
      widget.controller.showFormattingToolbar();
    }
  }
  
  /// Apply formatting to the selected text
  void applyFormattingToSelection(TextFormatting formatting) {
    if (!_selection.isCollapsed) {
      final start = _selection.start;
      final end = _selection.end;
      
      // Update the model
      textBlock.applyFormatting(start, end, formatting);
      
      // Update the view
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use RichText for displaying formatted text when not editing
          if (!widget.focusNode.hasFocus)
            RichText(
              text: TextSpan(
                children: textBlock.buildTextSpans(),
              ),
              onTap: () {
                widget.focusNode.requestFocus();
              },
            )
          else
            // Use TextField for editing
            TextField(
              controller: textController,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: textBlock.defaultFormatting.toTextStyle(),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onSelectionChanged: (selection, _) {
                _updateSelection(selection);
              },
            ),
        ],
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
