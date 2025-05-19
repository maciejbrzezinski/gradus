# Gradus - Application Mechanism Design

## Overview

Gradus is a hybrid application combining the flexibility of Notion-like document editing with the functionality of a todo application that supports repetitive tasks. The application allows users to create and manage various types of content blocks in a fluid, intuitive interface.

## Core Architecture

### Data Model

The application will be built using a hierarchical data model:

```
- Document
  - Block[]
    - id: String
    - type: BlockType (text, list, todo, toggle, divider, header, image, file)
    - content: dynamic (depends on type)
    - metadata: Map<String, dynamic> (additional properties based on type)
    - children: Block[] (for nested blocks like in toggle lists)
```

#### Block Types

Each block type will have specific properties:

1. **Text Block**
   - content: String
   - formatting: TextFormatting (bold, italic, underline, etc.)

2. **List Block**
   - content: String
   - listType: ListType (bullet, numbered)
   - indentLevel: int

3. **Todo Block**
   - content: String
   - completed: bool
   - dueDate: DateTime?
   - repetition: RepetitionRule?

4. **Toggle Block**
   - content: String
   - isExpanded: bool
   - children: Block[]

5. **Divider Block**
   - style: DividerStyle

6. **Header Block**
   - content: String
   - level: int (1-3 for h1, h2, h3)

7. **Image Block**
   - source: String (path or URL)
   - caption: String?
   - dimensions: Size?

8. **File Block**
   - filename: String
   - fileSize: int
   - fileType: String
   - path: String

### Repetition Rules

For todo items that repeat, we'll implement a flexible repetition system:

```dart
class RepetitionRule {
  RepetitionType type; // daily, weekly, monthly, custom
  int interval; // every X days/weeks/months
  List<int> daysOfWeek; // for weekly repetition
  int dayOfMonth; // for monthly repetition
  DateTime? endDate;
  int? maxOccurrences;
}
```

## UI Components

### Main Screen Structure

```
- AppBar (with document title, search, user profile)
- DocumentView
  - BlockList (main content area)
  - CommandPalette (appears when '/' is typed)
  - BlockFormatToolbar (appears when text is selected)
- BottomNavigationBar (for switching between documents/views)
```

### Block Rendering

Each block type will have a dedicated widget for rendering:

```dart
abstract class BlockWidget extends StatefulWidget {
  final Block block;
  final BlockController controller;
  
  // Common methods for all block types
}

class TextBlockWidget extends BlockWidget { ... }
class ListBlockWidget extends BlockWidget { ... }
class TodoBlockWidget extends BlockWidget { ... }
// etc.
```

## Interaction Mechanisms

### Block Editing

1. **Focus Management**
   - Each block will have its own focus node
   - When a block receives focus, it will show appropriate helpers/toolbars
   - Arrow keys will navigate between blocks

2. **Command Detection**
   - The editor will detect when '/' is typed at the beginning of a line or as the last character
   - This will trigger the CommandPalette to appear with block type options
   - Users can select options with arrow keys + enter or by clicking

3. **Block Conversion**
   - When a block type is selected from the CommandPalette, the current block will be converted to the new type
   - The conversion will preserve content where applicable

4. **Empty Block Deletion**
   - When backspace is pressed on an empty block, the block will be deleted
   - Focus will move to the previous block
   - The first block in a document cannot be deleted this way (will be converted to text instead)

### Todo Functionality

1. **Task Creation**
   - Todo blocks can be created via the '/' command
   - They will have a checkbox, content area, and optional metadata (due date, repetition)

2. **Task Completion**
   - Clicking the checkbox marks a task as complete
   - For repeating tasks, marking as complete will:
     - Update the current instance as complete
     - Generate the next occurrence based on repetition rules
     - Add the new occurrence to the appropriate position in the document

3. **Repetition Management**
   - Users can set repetition rules via a popup dialog
   - The dialog will offer presets (daily, weekly, etc.) and custom options
   - Repeating tasks will show a visual indicator

## State Management

The application will use a combination of state management approaches:

1. **Document State**
   - A central document store will maintain the overall structure
   - This will handle persistence, undo/redo, and synchronization

2. **Block-level State**
   - Each block will manage its own local state for editing and interaction
   - Changes will be propagated to the document store

3. **Application State**
   - Global app state will manage user preferences, active document, etc.

```dart
class DocumentStore {
  List<Block> blocks;
  
  void addBlock(Block block, {int? index});
  void removeBlock(String blockId);
  void updateBlock(String blockId, Block updatedBlock);
  void reorderBlocks(String blockId, int newIndex);
  
  // History management
  void undo();
  void redo();
  
  // Persistence
  Future<void> saveDocument();
  Future<void> loadDocument(String documentId);
}
```

## Implementation Details

### Block Editing Flow

1. User clicks on a block or creates a new one (initially a text block)
2. The block receives focus and shows appropriate editing UI
3. User types content or uses formatting controls
4. If user types '/', the CommandPalette appears
5. User selects a block type from the palette
6. The block is converted to the selected type
7. User continues editing with type-specific controls

### Command Palette Implementation

The CommandPalette will be implemented as an overlay that appears when '/' is detected:

```dart
class CommandPalette extends StatefulWidget {
  final TextEditingController textController;
  final Function(BlockType) onBlockTypeSelected;
  
  @override
  _CommandPaletteState createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  String _searchQuery = '';
  List<BlockTypeOption> _filteredOptions = [];
  
  @override
  void initState() {
    super.initState();
    _filteredOptions = _getAllBlockTypeOptions();
    
    // Listen for changes in the text field
    widget.textController.addListener(_onTextChanged);
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
      _filteredOptions = _getAllBlockTypeOptions()
          .where((option) => option.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }
  
  List<BlockTypeOption> _getAllBlockTypeOptions() {
    return [
      BlockTypeOption(BlockType.text, 'Text', Icons.text_fields),
      BlockTypeOption(BlockType.list, 'List', Icons.list),
      BlockTypeOption(BlockType.todo, 'Todo', Icons.check_box_outline_blank),
      // etc.
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Position below the current cursor
      child: Card(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredOptions.length,
          itemBuilder: (context, index) {
            final option = _filteredOptions[index];
            return ListTile(
              leading: Icon(option.icon),
              title: Text(option.title),
              onTap: () => widget.onBlockTypeSelected(option.type),
            );
          },
        ),
      ),
    );
  }
}
```

### Todo Repetition Logic

For repeating tasks, we'll implement a scheduler that calculates the next occurrence:

```dart
class TaskScheduler {
  DateTime calculateNextOccurrence(DateTime currentDate, RepetitionRule rule) {
    switch (rule.type) {
      case RepetitionType.daily:
        return currentDate.add(Duration(days: rule.interval));
        
      case RepetitionType.weekly:
        // Find the next day of week that matches the rule
        var nextDate = currentDate.add(Duration(days: 1));
        while (!rule.daysOfWeek.contains(nextDate.weekday)) {
          nextDate = nextDate.add(Duration(days: 1));
        }
        return nextDate;
        
      case RepetitionType.monthly:
        // Move to the same day in the next month
        var nextMonth = currentDate.month + rule.interval;
        var nextYear = currentDate.year;
        
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        
        return DateTime(nextYear, nextMonth, rule.dayOfMonth);
        
      case RepetitionType.custom:
        // Custom logic based on rule parameters
        return _calculateCustomRepetition(currentDate, rule);
    }
  }
  
  DateTime _calculateCustomRepetition(DateTime currentDate, RepetitionRule rule) {
    // Custom repetition logic
    return currentDate;
  }
  
  bool isTaskDue(DateTime taskDate, DateTime currentDate) {
    // Check if a task is due based on its date and the current date
    return taskDate.year == currentDate.year &&
           taskDate.month == currentDate.month &&
           taskDate.day == currentDate.day;
  }
}
```

## Persistence and Synchronization

The application will store data locally and optionally sync with a cloud service:

1. **Local Storage**
   - Documents will be stored as JSON in local storage
   - Each document will have a unique identifier
   - Changes will be saved automatically after a short delay

2. **Cloud Synchronization** (future feature)
   - Documents can be synced with a backend service
   - Changes will be tracked and merged using operational transformation
   - Conflicts will be resolved using a last-write-wins strategy with manual override

## Performance Considerations

1. **Virtualized List**
   - For long documents, we'll use a virtualized list that only renders visible blocks
   - This ensures smooth scrolling even with hundreds of blocks

2. **Lazy Loading**
   - Images and files will be loaded lazily as they come into view
   - Thumbnails will be generated for quick preview

3. **Incremental Updates**
   - Only changed blocks will be re-rendered
   - The document store will track changes efficiently

## Accessibility

1. **Keyboard Navigation**
   - Full keyboard support for all operations
   - Keyboard shortcuts for common actions

2. **Screen Reader Support**
   - Semantic labels for all interactive elements
   - Proper ARIA roles for custom widgets

3. **High Contrast Mode**
   - Support for system high contrast settings
   - Custom high contrast theme

## Future Extensions

1. **Collaboration**
   - Real-time collaborative editing
   - Presence indicators
   - Comments and suggestions

2. **Advanced Formatting**
   - Code blocks with syntax highlighting
   - Tables
   - Embeds (videos, maps, etc.)

3. **AI Integration**
   - Smart task suggestions
   - Content summarization
   - Automatic categorization
