# Gradus - Architecture Summary

This document provides an overview of the Gradus application architecture.

## Application Overview

Gradus is a hybrid application combining Notion-like document editing with todo functionality that supports repetitive tasks. Key features:

- Endless timeline for scrolling through days/weeks
- Rich inline text formatting
- Multiple block types (text, lists, todos, toggles, etc.)
- First-class task management with repetition
- Offline-first architecture with synchronization

## Authentication and User Management

### Authentication Approach

The authentication system follows these principles:

- **Separation from core functionality** - Authentication logic is isolated from the main application features
- **Persistent sessions** - Long-lived sessions with automatic token refresh
- **Offline capabilities** - Authentication state persists across app restarts
- **Progressive enrollment** - Users can start using the app before creating an account

### Authentication Methods

Gradus supports multiple authentication methods through Supabase:

- **Email/Password** - Traditional signup and login with email verification
- **Google Authentication** - Single-sign-on with Google accounts
- **Anonymous sessions** - Usage without account creation (data stored locally only)

### Authentication Flow

The authentication flow is designed to be fast and provide excellent UX:

1. **Initial App Launch**
   - App checks for existing session
   - If valid session exists, user proceeds directly to content
   - If no session, user is presented with sign in screen

2. **Token Management**
   - Access tokens stored using shared preferences
   - Automatic refresh of expired tokens
   - Transparent retry of failed requests due to token expiration

### Authentication Pages

The authentication flow includes these key screens:

1. **Sign In Screen**
   - Email/password input fields
   - Google sign-in button
   - "Forgot password" option
   - Error handling with user-friendly messages

2. **Sign Up Screen**
   - Email/password fields with validation
   - Google sign-up option

3. **Password Reset Screen**
   - Email input for reset link
   - Confirmation message with next steps
   - Return to sign-in option

4. **Account Management Screen**
   - Password change
   - Account deletion option
   - Profile information management
   - Sign out option

### Performance Optimizations

To ensure authentication is "super fast":

1. **Parallel Initialization**
   - Authentication initialization runs concurrently with app startup
   - UI rendering begins before authentication completes

2. **Cached Credentials**
   - Session tokens stored in shared preferences
   - Automatic session restoration without user input

3. **Preloaded Components**
   - Authentication UI components preloaded during splash screen
   - Immediate display when needed without loading delay

4. **Optimistic UI Updates**
   - UI updates immediately on authentication actions
   - Background validation and error handling if needed

5. **Streamlined API Communication**
   - Minimal API calls during authentication process
   - Efficient payload size for faster network operations

## Main Application Views

Gradus offers two primary views:

### Timeline View
- Vertical day-by-day scrolling interface
- Each day is a separate document with notes and tasks
- Infinite scrolling in both directions with lazy loading
- Days remain virtual (not stored) until content is added
- Tasks with due dates appear on their respective days
- Completing a repeating task creates a new instance on a future date
- Holiday calendar integration (enabled by default, can be disabled) displays national holidays, cultural events, and important dates like Valentine's Day, Mother's Day, etc.

#### Endless Timeline Implementation
- **Center Index Approach** - Uses an arbitrary large index (e.g., 10000) as the center point mapped to the current date
- **Bidirectional Scrolling** - Enables navigation both into the past (indices below center) and future (indices above center)
- **Date-Index Mapping** - Dynamically calculates dates based on their offset from the center index
- **Initial Positioning** - Timeline initializes with the scroll position at the center index
- **Virtual Day Rendering** - Only renders days that are visible plus a buffer for smooth scrolling
- **Document Lazy Loading** - Documents are only fetched from storage when their date is getting closer to the visible range

### Project View
- Single document not tied to a specific date
- Contains notes, tasks, and other block types
- Tasks with dates also appear in the timeline view
- For repeating tasks, completed instances are replaced in the project view to avoid clutter, but remain visible in the timeline to preserve completion history
- Includes two distinct views:
  - **Document View** - Standard project document view with all content
  - **Project Timeline** - Timeline view showing only project-related items
  - Notes assigned to days on the timeline also appear in the main timeline view

## Architecture Approach

Gradus follows Clean Architecture with BLoC pattern for state management, providing:

- **Separation of concerns** - Each layer has a single responsibility
- **Dependency rule** - Dependencies point inward
- **Testability** - Each component can be tested in isolation
- **Flexibility** - Easy to swap implementations
- **Scalability** - New features can be added without disrupting existing functionality
- **Responsive Design** - Application designed for both mobile and desktop screen sizes

### Architecture Layers

1. **Presentation Layer** - UI Components and BLoCs/Cubits
2. **Domain Layer** - Entities, Use Cases, and Repository Interfaces
3. **Data Layer** - Repositories, Data Sources, and Models

### Code Generation and Models

The application uses **Freezed** for model generation

## Core Data Model

The core data model uses blocks as fundamental building blocks of documents, with a base Document class and specialized variants:

```
- Document (abstract base class)
  - date: DateTime? // If set, then this is a timeline document
  - title: String? // Project title
  - icon: String? // Project icon
  - iconColor: Color? // Project icon color
  - id: String
  - blocks: List<String> // Ordered array of block IDs
  
- Block (abstract base class)
  - id: String
  - type: BlockType
  - content: dynamic
  - metadata: Map<String, dynamic>
  - children: Block[]
  - projectId: String? // If block belongs to a project
  - date: DateTime? // If block belongs to a specific day in timeline, prpoject and date can be set at the sam,e time and it's ok
```

Block types include Text, List, Todo, Toggle, Divider, Header, Image, and File blocks, each with specific properties.

### Repetition Rules

Todo items can implement a flexible repetition system:

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

Each repetition type has a distinct visual indicator through color coding to provide immediate recognition of task scheduling patterns.

## User Interaction

### Rich Text Formatting

The rich text formatting system provides inline styling capabilities, allowing different parts of text to have various formatting attributes:

- **Text Formatting Model** - Based on a `TextFormatting` class that defines style attributes (bold, italic, underline, strikethrough, color, background color, font family, font size)
- **Span-based Approach** - Uses `FormattedSpan` objects that define ranges of text with specific formatting applied
- **Fragmentation Algorithm** - Text with overlapping formatting is split into fragments with unique combinations of formatting attributes:
  - Each point where formatting changes creates a text fragment boundary
  - Fragments have combined styles from all applicable formatting spans
  - Fragments are rendered as separate `TextSpan` objects with appropriate styling

### Custom Text Editor

Text editing is implemented using a custom RenderObject-based approach:

- **Complete Rendering Control** - Built from scratch for precise control over every visual aspect
- **Custom Input Handling** - Specialized input handling for keyboard, touch, and mouse interactions
- **Cursor and Selection Management** - Custom implementation of cursor rendering, movement, and text selection
- **Performance Optimizations** - Efficient handling of text rendering and formatting changes:
  - Incremental updates to affected text fragments only
  - Caching of rendered text spans
  - Compositor-friendly layer management
  - Asynchronous formatting calculations where appropriate

### Block Editing

- **Focus Management** - Each block has its own focus node with navigation between blocks
- **Command Detection** - '/' command triggers options for block types
- **Block Conversion** - Blocks can be converted between types while preserving content
- **Empty Block Deletion** - Empty blocks are deleted on backspace

### Todo Functionality

- **Task Creation** - Todo blocks with checkbox, content, and metadata (due date, repetition)
- **Task Completion** - Marks tasks complete and generates next occurrence for repeating tasks
- **Repetition Management** - Rules set via dialog with presets and custom options
- **Visual Repetition Indicators** - Color-coded left border on task widgets that subtly indicates repetition type

### Cross-View Tasks and Sorting

- **Project Tasks on Timeline** - Tasks with due dates from projects appear on timeline on their respective dates
- **Virtual References** - Project tasks are displayed as references in timeline view, not duplicated
- **Document-Level Sorting** - Each document maintains its own ordered array of blocks:
  ```dart
  Document {
    id: String,
    blocks: List<String>, // Ordered array of block IDs
    // ... other properties
  }
  
  Block {
    id: String,
    type: BlockType,
    content: dynamic,
    metadata: Map<String, dynamic>, // No position data stored here
    // ... other properties
  }
  ```
- **Independent Sorting Relations** - Each view maintains its own one-to-many sorting relationship:
  - Timeline documents have their own `blocks` array with order specific to that day
  - Project documents have their own `blocks` array with project-specific order
- **Drag-and-Drop Support** - Block reordering modifies the document's blocks array:
  - Adding a block: append block ID to the document's blocks array
  - Moving a block: change its position in the document's blocks array
  - Removing a block: remove block ID from the document's blocks array
  - Blocks don't need to know their position - the document array provides the order

## Block Implementation System

Gradus uses a hybrid approach for implementing various block types, combining custom RenderObject-based rendering with Flutter widgets for optimal flexibility and performance.

### Hybrid Rendering Architecture

The block system implements a two-level architecture:

- **Core Rendering Level** - Uses custom RenderObject implementations for text rendering, selection handling, and input management
- **Widget Structure Level** - Uses Flutter widgets for block containers, animations, and specialized UI elements

This hybrid approach provides:
- Consistent text formatting across all block types
- Optimal performance for text-heavy operations
- Flexibility for implementing complex block behaviors

### Block Types Implementation

#### Text Blocks
- **Paragraph**
  - **Structure**: Basic text block with full formatting support
  - **Features**:
    - Complete rich text formatting (bold, italic, underline, etc.)
    - Support for inline links and mentions
    - Automatic conversion to other block types based on input patterns

#### Heading Blocks
- **Heading 1**
  - **Structure**: Large heading with prominent styling
  - **Features**:
    - Largest font size with distinctive weight
    - Rich text formatting support
    
- **Heading 2**
  - **Structure**: Medium-sized heading for section organization
  - **Features**:
    - Medium font size with distinctive styling
    - Rich text formatting support
    
- **Heading 3**
  - **Structure**: Smaller heading for subsection organization
  - **Features**:
    - Smaller but still distinctive font styling
    - Rich text formatting support

#### List Blocks
- **Bulleted List**
  - **Structure**: Unordered list with bullet markers
  - **Features**:
    - Multiple bullet style options (•, -, ○)
    - Multi-level nesting with different marker styles per level
    - Rich text formatting within list items
    - Automatic continuation when pressing Enter
    
- **Numbered List**
  - **Structure**: Ordered list with sequential numbering
  - **Features**:
    - Multiple numbering styles (1., a., i., etc.)
    - Automatic number sequencing
    - Multi-level nesting with different numbering styles
    - Rich text formatting within list items

#### Task Blocks
- **Todo Block**
  - **Structure**: Checkbox with associated text and metadata
  - **Features**:
    - Toggle-able completion state
    - Optional due date
    - Rich text formatting in task description
    - Recurring task options with flexible scheduling patterns
    - Visual distinction between completed and pending tasks
    - Visual repetition indicators through color-coded left border:
      - Daily tasks: Blue (#2563EB) border
      - Weekly tasks: Green (#059669) border
      - Monthly tasks: Orange (#EA580C) border
      - Custom repetition: Purple (#7C3AED) border

#### Toggle Blocks
- **Structure**: Header text with collapsible content blocks
- **Behavior**: Expandable container with animated transitions
- **Features**: 
  - Rich text formatting in header using the shared formatting system
  - Smooth expand/collapse animations
  - Nested block support in content area
  - Memory of collapsed/expanded state between sessions

#### Formatting Blocks
- **Quote Block**
  - **Structure**: Visually distinguished block for quotations
  - **Features**:
    - Distinctive styling with vertical accent line or background
    - Rich text formatting within the quote
    - Optional attribution/citation support
    
- **Divider Block**
  - **Structure**: Horizontal line separator
  - **Features**:
    - Multiple style options (solid, dashed, dotted)
    - Customizable thickness and color
    - Used to visually separate document sections
    
- **Callout Block**
  - **Structure**: Highlighted block with icon and background color
  - **Features**:
    - Multiple preset styles (info, warning, success, etc.)
    - Customizable icons and background colors
    - Rich text formatting within the callout
    - Visual emphasis for important information

#### Code Blocks
- **Structure**: Syntax-highlighted code with optional line numbers
- **Features**:
  - Language detection and syntax highlighting for multiple programming languages
  - Monospace font rendering with proper spacing
  - Optional line numbers and copy functionality
  - Specialized input handling preserving indentation
  - Support for horizontal scrolling for long lines

#### Media Blocks
- **Image Block**
  - **Structure**: Embedded image with optional caption
  - **Features**:
    - Support for multiple image formats
    - Resizable with aspect ratio maintenance
    - Optional caption with rich text formatting
    - Lazy loading for performance optimization
    - Click to expand/zoom functionality

### Common Formatting Interface

All block types that contain text implement a common formatting interface to ensure consistent behavior across the application. This enables:

- Unified formatting commands (bold, italic, etc.) that work identically across all block types
- Consistent cursor behavior and selection management
- Seamless copying and pasting of formatted content between blocks

### Block Animation System

The animation system provides smooth transitions between block states and types:

- **Block Type Conversion**: Seamless animations when converting between block types
- **State Changes**: Fluid transitions for expanding/collapsing toggles and other state changes
- **Block Reordering**: Dynamic animations when dragging and reordering blocks

The animation system ensures:
- Visually coherent transitions between block states
- Smooth conversion between different block types
- Consistent animation timing and curves throughout the application

### Block Transformation System

The transformation system manages conversions between block types:

- **Content Preservation**: Maintains text content and formatting during conversions
- **Smart Transformations**: Intelligently maps structure from source to target block type
- **Undo Support**: Tracks transformations to support reverting changes

### Focus and Navigation Management

A dedicated focus management system coordinates focus and navigation between blocks:

- **Sequential Navigation**: Tab/Shift+Tab to move between blocks
- **Intelligent Enter Behavior**: Context-aware behavior for the Enter key (create new block, continue list, etc.)
- **Smart Backspace Handling**: Delete empty blocks or join with previous block

## State Management and Data Flow

Gradus uses two BLoC pattern components:
- **Cubits** - For straightforward state management
- **BLoCs** - For complex event handling

Key components include DocumentCubit, BlockCubit, and CommandPaletteCubit.

### Data Flow Path

1. **User Input** → UI → BLoC/Cubit → Use Case → Repository → Data Source → Storage
2. **Data Updates** → Local SQLite → Application State → Background Sync to Supabase
3. **Document Type Handling** → Specialized handling based on TimelineDocument or ProjectDocument type

## Storage and Synchronization Strategy

Gradus implements a comprehensive storage and synchronization system:

### Storage Components

- **Primary Storage**: SQLite with Brick as data manager
  - Fast local persistence without network dependency
  - Optional memory cache for frequently accessed data

- **Cloud Synchronization**: Optional Supabase integration
  - Multi-device synchronization
  - Automatic offline queue management through Brick
  - Conflict resolution for concurrent edits

### RealtimeSyncService

A centralized component that manages real-time synchronization:

```dart
class RealtimeSyncService {
  // Registers models for real-time sync
  void registerModel<T>({required String tableName, required String primaryKey, ...}) { ... }
  
  // Handles real-time events (INSERT, UPDATE, DELETE)
  void _handleRealtimeEvent<T>(PostgresChangePayload payload, ...) { ... }
}
```

This service:
- Manages Supabase Realtime channel subscriptions
- Processes events and updates local SQLite database
- Immediately reflects changes in UI when updates are received
- Uses debounced auto-save for edits without manual save actions
- Properly handles task repetition (new instances in timeline, replacement in projects to avoid clutter while preserving completion history in timeline)
- Provides type-safe handling through a registration system
- Integrates with the repository pattern

### Offline Queue Management

Brick automatically handles offline operations without requiring custom implementation:

- **Automatic Queueing** - Operations performed while offline are automatically queued
- **Transparent Retry** - Queued operations are continuously retried until connection is restored
- **Repository Integration** - Offline queue is configured during Repository initialization
- **Zero Configuration** - No additional setup required beyond standard Brick configuration

## Performance and Accessibility

### Performance Optimizations
- Virtualized lists for efficient rendering
- Lazy loading for timeline scrolling (loads only visible days + buffer)
- Virtual days that only persist when content is added
- Lazy loading for images and files
- Incremental updates for changed blocks only

#### Timeline Performance Considerations
- **Scroll Position Management** - Maintains the scroll position relative to the center index during re-renders
- **Efficient Timeline Navigation** - Bidirectional scrolling is achieved without duplicating the entire timeline structure
- **Memory Optimization** - Only days with content consume storage space
- **Day Buffer System** - Maintains a configurable buffer of days beyond the visible area for smooth scrolling
- **Date Calculation Efficiency** - Uses direct mathematical transformation between index and date for constant-time lookups
- **Variable Day Height** - Optimizes rendering by adjusting day tile height based on content density
