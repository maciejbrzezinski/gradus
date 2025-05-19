# Gradus - Architecture Summary

This document provides a comprehensive overview of the Gradus application architecture, summarizing the key aspects from the detailed design documents.

## Application Overview

Gradus is a hybrid application combining the flexibility of Notion-like document editing with the functionality of a todo application that supports repetitive tasks. It features:

- An endless timeline for scrolling through days and weeks
- Rich inline formatting for text
- Support for various block types (text, lists, todos, toggles, etc.)
- First-class task management with repetition capabilities
- Offline-first architecture with eventual synchronization

## Architecture Approach

Gradus follows Clean Architecture principles with the BLoC pattern for state management, as described in the project README. This approach provides:

- **Separation of concerns** - Each layer has a single responsibility
- **Dependency rule** - Dependencies point inward (outer layers depend on inner layers)
- **Testability** - Each component can be tested in isolation
- **Flexibility** - Easy to swap implementations (e.g., storage mechanisms)
- **Scalability** - New features can be added without disrupting existing functionality

### Architecture Layers

The application is divided into three main layers:

1. **Presentation Layer**
   - UI Components (Flutter widgets)
   - BLoCs/Cubits (State management)

2. **Domain Layer**
   - Entities (Core business objects)
   - Use Cases (Business logic operations)
   - Repository Interfaces (Abstract definitions of data operations)

3. **Data Layer**
   - Repositories (Implementations of domain repository interfaces)
   - Data Sources (Concrete data access mechanisms)
   - Models (Data transfer objects that map to/from entities)

## Core Data Model

The core data model revolves around the concept of blocks, which are the fundamental building blocks of documents:

```
- Document
  - Block[]
    - id: String
    - type: BlockType (text, list, todo, toggle, divider, header, image, file)
    - content: dynamic (depends on type)
    - metadata: Map<String, dynamic> (additional properties based on type)
    - children: Block[] (for nested blocks like in toggle lists)
```

Each block type has specific properties and behaviors:

1. **Text Block** - Basic text content with formatting options
2. **List Block** - Ordered or unordered lists with indentation
3. **Todo Block** - Tasks with completion status, due dates, and repetition rules
4. **Toggle Block** - Collapsible content with children
5. **Divider Block** - Visual separator
6. **Header Block** - Section headings with different levels
7. **Image Block** - Embedded images with captions
8. **File Block** - Attached files with metadata

### Repetition Rules

For todo items that repeat, we implement a flexible repetition system:

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

## Key Interaction Mechanisms

### Block Editing

1. **Focus Management**
   - Each block has its own focus node
   - When a block receives focus, it shows appropriate helpers/toolbars
   - Arrow keys navigate between blocks

2. **Command Detection**
   - The editor detects when '/' is typed at the beginning of a line or as the last character
   - This triggers the CommandPalette to appear with block type options
   - Users can select options with arrow keys + enter or by clicking

3. **Block Conversion**
   - When a block type is selected from the CommandPalette, the current block is converted to the new type
   - The conversion preserves content where applicable

4. **Empty Block Deletion**
   - When backspace is pressed on an empty block, the block is deleted
   - Focus moves to the previous block
   - The first block in a document cannot be deleted this way (will be converted to text instead)

### Todo Functionality

1. **Task Creation**
   - Todo blocks can be created via the '/' command
   - They have a checkbox, content area, and optional metadata (due date, repetition)

2. **Task Completion**
   - Clicking the checkbox marks a task as complete
   - For repeating tasks, marking as complete will:
     - Update the current instance as complete
     - Generate the next occurrence based on repetition rules
     - Add the new occurrence to the appropriate position in the document

3. **Repetition Management**
   - Users can set repetition rules via a popup dialog
   - The dialog offers presets (daily, weekly, etc.) and custom options
   - Repeating tasks show a visual indicator

## State Management with BLoC Pattern

Gradus uses two types of BLoC pattern components:

1. **Cubits** - Simplified BLoCs for straightforward state management
   - Used for most features where complex event handling is not required
   - Directly exposes methods that emit new states

2. **BLoCs** - Full BLoC implementation for complex event handling
   - Used when sophisticated event manipulation is needed
   - Follows the event-to-state transformation pattern

### Key Cubits/BLoCs

1. **DocumentCubit**
   - Manages the state of the current document
   - Handles loading, saving, and updating documents

2. **BlockCubit**
   - Manages the state of individual blocks
   - Handles creating, updating, and converting blocks

3. **CommandPaletteCubit**
   - Manages the state of the command palette
   - Handles showing, hiding, and filtering options

## Data Flow

The data flow in the application follows these steps:

1. **User Interaction** → UI captures user input
2. **UI to BLoC/Cubit** → UI calls methods on BLoC/Cubit
3. **BLoC/Cubit to Use Case** → BLoC/Cubit calls appropriate use case
4. **Use Case to Repository** → Use case executes business logic and calls repository
5. **Repository to Data Source** → Repository decides which data source to use
6. **Data Source to Storage** → Data source performs actual data operations

For data updates:
1. **Repository** → Maintains and emits updates through streams
2. **Use Case** → Processes data if needed
3. **BLoC/Cubit** → Listens to streams and updates state
4. **UI** → Rebuilds based on new state

## Storage Strategy

Gradus implements a flexible storage strategy:

1. **Default: SharedPreferences**
   - Primary local storage mechanism
   - Stores data in key-value pairs
   - Fast and efficient for small to medium data sets

2. **Optional: Online Synchronization** (future feature)
   - Can be enabled/disabled by the user
   - When enabled, data is synchronized with a remote server
   - Implements a well-defined API that must be supported by any remote data source

## Performance Considerations

1. **Virtualized List**
   - For long documents, we use a virtualized list that only renders visible blocks
   - This ensures smooth scrolling even with hundreds of blocks

2. **Lazy Loading**
   - Images and files are loaded lazily as they come into view
   - Thumbnails are generated for quick preview

3. **Incremental Updates**
   - Only changed blocks are re-rendered
   - The document store tracks changes efficiently

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

## Implementation Plan

The implementation follows a structured approach:

1. **Core Data Models**
   - Implement the base Block class and its derivatives
   - Implement the Document model
   - Implement the RepetitionRule model

2. **Repository Interfaces and Implementations**
   - Define repository interfaces in the domain layer
   - Implement repositories in the data layer
   - Implement data sources for local storage

3. **Use Cases**
   - Implement use cases for all business operations
   - Ensure proper error handling with Either type

4. **BLoCs/Cubits**
   - Implement state management for documents, blocks, and UI components
   - Define clear states and events

5. **UI Components**
   - Implement base widgets for blocks
   - Implement specialized widgets for each block type
   - Implement the command palette and formatting toolbar

6. **Integration**
   - Connect all layers together
   - Set up dependency injection
   - Implement navigation and routing

## Alignment with Project Requirements

The architecture aligns perfectly with the requirements specified in the README:

1. **Endless timeline**
   - The document model supports an infinite number of blocks
   - The UI implements virtualized rendering for performance

2. **Rich inline formatting**
   - Text blocks support various formatting options
   - The formatting toolbar provides easy access to styling options

3. **Inline images**
   - Image blocks support embedding images directly in the document
   - Images can be resized and captioned

4. **First-class tasks**
   - Todo blocks are a core block type
   - Tasks support due dates, repetition, and completion tracking

5. **Offline-first**
   - All data is stored locally first
   - Synchronization is optional and happens in the background

6. **Plugin architecture**
   - The block system is extensible
   - New block types can be added without changing the core architecture

## Conclusion

The Gradus application architecture provides a solid foundation for building a powerful and flexible note-taking and task management application. By following Clean Architecture principles and using the BLoC pattern for state management, the application is maintainable, testable, and scalable.

The core data model based on blocks allows for a wide range of content types and formatting options, while the repetition system for tasks provides powerful task management capabilities. The offline-first approach ensures that users can work without an internet connection, and the optional synchronization feature allows for seamless multi-device usage.
