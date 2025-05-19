# Gradus - Architecture Diagrams

This document provides visual representations of the Gradus application architecture using Mermaid diagrams.

## Clean Architecture Overview

```mermaid
graph TD
    subgraph "Presentation Layer"
        UI[UI Components]
        BLoC[BLoCs/Cubits]
        UI -->|User Events| BLoC
        BLoC -->|State Updates| UI
    end
    
    subgraph "Domain Layer"
        Entities[Entities]
        UseCases[Use Cases]
        Repos[Repository Interfaces]
        UseCases -->|Uses| Entities
        UseCases -->|Depends on| Repos
    end
    
    subgraph "Data Layer"
        RepoImpl[Repository Implementations]
        DataSources[Data Sources]
        Models[Models]
        RepoImpl -->|Uses| DataSources
        RepoImpl -->|Maps| Models
        Models -->|Maps to/from| Entities
    end
    
    BLoC -->|Calls| UseCases
    RepoImpl -->|Implements| Repos
```

## Block Type Hierarchy

```mermaid
classDiagram
    class Block {
        +String id
        +BlockType type
        +dynamic content
        +Map<String, dynamic> metadata
        +List<Block> children
    }
    
    class TextBlock {
        +String textContent
        +TextFormatting formatting
    }
    
    class ListBlock {
        +String textContent
        +ListType listType
        +int indentLevel
    }
    
    class TodoBlock {
        +String textContent
        +bool completed
        +DateTime? dueDate
        +RepetitionRule? repetition
    }
    
    class ToggleBlock {
        +String textContent
        +bool isExpanded
    }
    
    class DividerBlock {
        +DividerStyle style
    }
    
    class HeaderBlock {
        +String textContent
        +int level
    }
    
    class ImageBlock {
        +String source
        +String? caption
        +Size? dimensions
    }
    
    class FileBlock {
        +String filename
        +int fileSize
        +String fileType
        +String path
    }
    
    Block <|-- TextBlock
    Block <|-- ListBlock
    Block <|-- TodoBlock
    Block <|-- ToggleBlock
    Block <|-- DividerBlock
    Block <|-- HeaderBlock
    Block <|-- ImageBlock
    Block <|-- FileBlock
```

## Document Structure

```mermaid
classDiagram
    class Document {
        +String id
        +String title
        +List<Block> blocks
        +DateTime createdAt
        +DateTime updatedAt
        +addBlock(Block, int?)
        +removeBlock(String)
        +updateBlock(String, Block)
        +reorderBlocks(String, int)
    }
    
    class Block {
        +String id
        +BlockType type
        +dynamic content
        +Map<String, dynamic> metadata
        +List<Block> children
    }
    
    Document "1" *-- "many" Block : contains
    Block "1" *-- "many" Block : children
```

## State Management Flow

```mermaid
sequenceDiagram
    participant UI as UI Component
    participant BLoC as BLoC/Cubit
    participant UC as Use Case
    participant Repo as Repository
    participant DS as Data Source
    participant Storage as Local Storage
    
    UI->>BLoC: User Action (e.g., updateBlock)
    BLoC->>UC: Call Use Case (e.g., UpdateBlock)
    UC->>Repo: Call Repository Method
    Repo->>DS: Call Data Source Method
    DS->>Storage: Perform Storage Operation
    Storage-->>DS: Operation Result
    DS-->>Repo: Result
    Repo-->>UC: Either<Failure, Success>
    UC-->>BLoC: Either<Failure, Success>
    BLoC-->>UI: New State
    
    Note over Repo,DS: Repository also maintains streams<br/>for reactive updates
    
    Repo->>BLoC: Stream Updates
    BLoC->>UI: State Updates from Stream
```

## Command Palette Flow

```mermaid
sequenceDiagram
    participant User
    participant Block as Block Widget
    participant CP as Command Palette
    participant BLoC as Block BLoC
    
    User->>Block: Types "/"
    Block->>CP: Show Command Palette
    User->>CP: Selects Block Type
    CP->>BLoC: Convert Block Type
    BLoC->>Block: Update Block
    Block->>User: Display Updated Block
```

## Todo Repetition Flow

```mermaid
sequenceDiagram
    participant User
    participant TB as Todo Block
    participant BLoC as Block BLoC
    participant TS as Task Scheduler
    participant Doc as Document
    
    User->>TB: Marks Todo as Complete
    TB->>BLoC: Update Todo Status
    BLoC->>TS: Calculate Next Occurrence
    TS->>BLoC: Next Occurrence Date
    BLoC->>Doc: Create New Todo with Next Date
    Doc->>User: Display Updated Document with New Todo
```

## Data Layer Implementation

```mermaid
classDiagram
    class DocumentRepository {
        <<interface>>
        +getDocument(String) Future<Either<Failure, Document>>
        +getAllDocuments() Future<Either<Failure, List<Document>>>
        +saveDocument(Document) Future<Either<Failure, void>>
        +deleteDocument(String) Future<Either<Failure, void>>
        +documentStream(String) Stream<Document>
        +allDocumentsStream() Stream<List<Document>>
    }
    
    class DocumentRepositoryImpl {
        -DocumentLocalDataSource localDataSource
        -StreamController<Document> _documentStreamController
        -StreamController<List<Document>> _allDocumentsStreamController
        +getDocument(String) Future<Either<Failure, Document>>
        +getAllDocuments() Future<Either<Failure, List<Document>>>
        +saveDocument(Document) Future<Either<Failure, void>>
        +deleteDocument(String) Future<Either<Failure, void>>
        +documentStream(String) Stream<Document>
        +allDocumentsStream() Stream<List<Document>>
    }
    
    class DocumentLocalDataSource {
        <<interface>>
        +getDocument(String) Future<DocumentModel>
        +getAllDocuments() Future<List<DocumentModel>>
        +saveDocument(DocumentModel) Future<void>
        +deleteDocument(String) Future<void>
    }
    
    class DocumentLocalDataSourceImpl {
        -SharedPreferences sharedPreferences
        +getDocument(String) Future<DocumentModel>
        +getAllDocuments() Future<List<DocumentModel>>
        +saveDocument(DocumentModel) Future<void>
        +deleteDocument(String) Future<void>
    }
    
    DocumentRepository <|.. DocumentRepositoryImpl
    DocumentLocalDataSource <|.. DocumentLocalDataSourceImpl
    DocumentRepositoryImpl --> DocumentLocalDataSource
```

## Presentation Layer Implementation

```mermaid
classDiagram
    class DocumentCubit {
        -GetDocument getDocument
        -SaveDocument saveDocument
        +loadDocument(String) Future<void>
        +updateDocument(Document) Future<void>
    }
    
    class DocumentState {
        <<abstract>>
    }
    
    class DocumentInitial {
    }
    
    class DocumentLoading {
    }
    
    class DocumentLoaded {
        +Document document
    }
    
    class DocumentError {
        +String message
    }
    
    DocumentState <|-- DocumentInitial
    DocumentState <|-- DocumentLoading
    DocumentState <|-- DocumentLoaded
    DocumentState <|-- DocumentError
    
    DocumentCubit --> DocumentState : emits
    DocumentCubit --> GetDocument : uses
    DocumentCubit --> SaveDocument : uses
```

## Widget Hierarchy

```mermaid
classDiagram
    class BlockWidget {
        <<abstract>>
        +Block block
        +FocusNode focusNode
        +bool isSelected
        +VoidCallback? onFocusChange
    }
    
    class BlockWidgetState {
        <<abstract>>
        +TextEditingController textController
        +String getBlockContent()
        +void updateBlockContent(String)
        +Widget build(BuildContext)
    }
    
    class TextBlockWidget {
    }
    
    class TextBlockWidgetState {
        +String getBlockContent()
        +void updateBlockContent(String)
        +Widget build(BuildContext)
    }
    
    class TodoBlockWidget {
    }
    
    class TodoBlockWidgetState {
        +String getBlockContent()
        +void updateBlockContent(String)
        +void _toggleCompleted()
        +void _showDatePicker()
        +void _showRepetitionDialog()
        +Widget build(BuildContext)
    }
    
    BlockWidget <|-- TextBlockWidget
    BlockWidget <|-- TodoBlockWidget
    BlockWidgetState <|-- TextBlockWidgetState
    BlockWidgetState <|-- TodoBlockWidgetState
```

## Dependency Injection

```mermaid
graph TD
    subgraph "Dependency Injection"
        GetIt[GetIt Service Locator]
    end
    
    subgraph "Presentation Layer"
        DocumentCubit[DocumentCubit]
        BlockCubit[BlockCubit]
        CommandPaletteCubit[CommandPaletteCubit]
    end
    
    subgraph "Domain Layer"
        GetDocument[GetDocument]
        SaveDocument[SaveDocument]
        CreateBlock[CreateBlock]
        UpdateBlock[UpdateBlock]
        ConvertBlockType[ConvertBlockType]
    end
    
    subgraph "Data Layer"
        DocumentRepositoryImpl[DocumentRepositoryImpl]
        BlockRepositoryImpl[BlockRepositoryImpl]
        DocumentLocalDataSourceImpl[DocumentLocalDataSourceImpl]
    end
    
    subgraph "External"
        SharedPreferences[SharedPreferences]
    end
    
    GetIt -->|registers| DocumentCubit
    GetIt -->|registers| BlockCubit
    GetIt -->|registers| CommandPaletteCubit
    GetIt -->|registers| GetDocument
    GetIt -->|registers| SaveDocument
    GetIt -->|registers| CreateBlock
    GetIt -->|registers| UpdateBlock
    GetIt -->|registers| ConvertBlockType
    GetIt -->|registers| DocumentRepositoryImpl
    GetIt -->|registers| BlockRepositoryImpl
    GetIt -->|registers| DocumentLocalDataSourceImpl
    GetIt -->|registers| SharedPreferences
    
    DocumentCubit -->|depends on| GetDocument
    DocumentCubit -->|depends on| SaveDocument
    BlockCubit -->|depends on| CreateBlock
    BlockCubit -->|depends on| UpdateBlock
    BlockCubit -->|depends on| ConvertBlockType
    GetDocument -->|depends on| DocumentRepositoryImpl
    SaveDocument -->|depends on| DocumentRepositoryImpl
    CreateBlock -->|depends on| BlockRepositoryImpl
    UpdateBlock -->|depends on| BlockRepositoryImpl
    ConvertBlockType -->|depends on| BlockRepositoryImpl
    DocumentRepositoryImpl -->|depends on| DocumentLocalDataSourceImpl
    DocumentLocalDataSourceImpl -->|depends on| SharedPreferences
```

## User Interface Layout

```mermaid
graph TD
    subgraph "Main Screen"
        AppBar[App Bar]
        DocumentView[Document View]
        BottomNav[Bottom Navigation Bar]
    end
    
    subgraph "Document View"
        BlockList[Block List]
        CommandPalette[Command Palette]
        FormatToolbar[Format Toolbar]
    end
    
    subgraph "Block List"
        TextBlock[Text Block]
        ListBlock[List Block]
        TodoBlock[Todo Block]
        ToggleBlock[Toggle Block]
        HeaderBlock[Header Block]
        ImageBlock[Image Block]
    end
    
    AppBar --> DocumentView
    DocumentView --> BottomNav
    DocumentView --> BlockList
    DocumentView --> CommandPalette
    DocumentView --> FormatToolbar
    BlockList --> TextBlock
    BlockList --> ListBlock
    BlockList --> TodoBlock
    BlockList --> ToggleBlock
    BlockList --> HeaderBlock
    BlockList --> ImageBlock
```

These diagrams provide a visual representation of the Gradus application architecture, showing the relationships between different components and the flow of data through the system.
