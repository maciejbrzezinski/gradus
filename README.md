# Gradus
> *Consistent steps toward mastery*

Gradus is a note-taking + task app that helps you trade short bursts of motivation for **steady, day-by-day progress**.  
It combines a powerful rich-text editor, lightweight task management and an **endless calendar scroll** into a single, offline-first Flutter application.

---

## Key Strengths

| 💪 Feature | 🚀 Gradus | ⚠️ Pain it solves |
|-----------|-----------|-------------------|
| **Endless timeline** | Scroll vertically through days & weeks; drop notes or todos anywhere in the flow | No more clicking into separate "pages" or databases—your past & future stay in one stream |
| **Rich inline formatting** | Bold, italic, highlight, inline code, callouts, nested lists, slash-commands | Superlist's plain-text style can't capture nuance or structure |
| **Inline images** | Paste or drag​&​drop ↔ see a live preview, pinch/drag to resize | Superlist forces a file download and won't let you shrink images in the editor |
| **Tasks are first-class** | Type `[]` or hit `⏎` to turn any line into a checklist, add due-dates & reminders | Notion hides tasks behind databases; setup is clunky for quick todos |
| **Offline-first** | Works underground, merges changes later without conflicts | Notion/Superlist need a live connection for most edits |
| **Plugin architecture** | Blocks for diagrams, code blocks with syntax, Mermaid, LaTeX (roadmap) | Extensibility without bloated workspaces |

---

## Architecture

Gradus implements **Clean Architecture** principles with **BLoC pattern** for state management. This architectural approach provides several key benefits:

- **Separation of concerns** - Each layer has a single responsibility
- **Dependency rule** - Dependencies point inward (outer layers depend on inner layers)
- **Testability** - Each component can be tested in isolation
- **Flexibility** - Easy to swap implementations (e.g., storage mechanisms)
- **Scalability** - New features can be added without disrupting existing functionality

### Layer Structure

The application is divided into three main layers:

#### 1. Presentation Layer

This is the outermost layer that contains:
- **UI Components** - Flutter widgets that display data and capture user input
- **BLoCs/Cubits** - State management components that react to user events and update UI

```dart
// Example of a Cubit
class NotesCubit extends Cubit<NotesState> {
  final GetNotes getNotesUseCase;
  final SaveNote saveNoteUseCase;
  
  NotesCubit({
    required this.getNotesUseCase,
    required this.saveNoteUseCase,
  }) : super(NotesInitial());
  
  Future<void> loadNotes() async {
    emit(NotesLoading());
    
    final result = await getNotesUseCase();
    
    result.fold(
      (failure) => emit(NotesError(message: failure.message)),
      (notes) => emit(NotesLoaded(notes: notes))
    );
  }
  
  // Other methods...
}
```

#### 2. Domain Layer

This is the core layer that contains:
- **Entities** - Core business objects
- **Use Cases** - Business logic operations
- **Repository Interfaces** - Abstract definitions of data operations

```dart
// Example of a Use Case
class GetNotes implements UseCase<List<Note>, NoParams> {
  final NotesRepository repository;
  
  GetNotes(this.repository);
  
  @override
  Future<Either<Failure, List<Note>>> call([NoParams params]) {
    return repository.getNotes();
  }
}
```

#### 3. Data Layer

This is the infrastructure layer that contains:
- **Repositories** - Implementations of domain repository interfaces
- **Data Sources** - Concrete data access mechanisms
- **Models** - Data transfer objects that map to/from entities

```dart
// Example of a Repository Implementation
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesRemoteDataSource? remoteDataSource;
  final NetworkInfo networkInfo;
  
  NotesRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();
      return Right(localNotes);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  // Stream is maintained at repository level
  final StreamController<List<Note>> _notesStreamController = StreamController<List<Note>>.broadcast();
  
  @override
  Stream<List<Note>> notesStream() {
    return _notesStreamController.stream;
  }
  
  // Other methods...
}
```

### State Management with BLoC Pattern

Gradus uses two types of BLoC pattern components:

1. **Cubits** - Simplified BLoCs for straightforward state management
   - Used for most features where complex event handling is not required
   - Directly exposes methods that emit new states

2. **BLoCs** - Full BLoC implementation for complex event handling
   - Used when sophisticated event manipulation is needed
   - Follows the event-to-state transformation pattern

```dart
// Example of when to use a full BLoC
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncDataUseCase syncDataUseCase;
  
  SyncBloc({required this.syncDataUseCase}) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<CancelSync>(_onCancelSync);
    on<SyncCompleted>(_onSyncCompleted);
    on<SyncFailed>(_onSyncFailed);
  }
  
  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    // Complex event handling logic...
  }
  
  // Other event handlers...
}
```

### Error Handling with Either

All use cases return an `Either` type from the `dartz` package, which represents either a success or failure:

```dart
Future<Either<Failure, Success>> operation() async {
  try {
    final result = await someOperation();
    return Right(result);  // Success case
  } catch (e) {
    return Left(Failure(e.toString()));  // Failure case
  }
}
```

This approach:
- Makes error handling explicit
- Forces developers to handle both success and failure cases
- Provides type safety for error handling

### Data Flow

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

Data sources are primarily responsible for making requests to fetch or save data, while repositories manage the streams that notify the application of data changes.

### Storage Strategy

Gradus implements a flexible storage strategy:

1. **Default: SharedPreferences**
   - Primary local storage mechanism
   - Stores data in key-value pairs
   - Fast and efficient for small to medium data sets

2. **Optional: Online Synchronization**
   - Can be enabled/disabled by the user
   - When enabled, data is synchronized with a remote server
   - Implements a well-defined API that must be supported by any remote data source

```dart
// Example of a Local Data Source
class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  NotesLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<NoteModel>> getNotes() {
    // Implementation using SharedPreferences to fetch data
  }
  
  @override
  Future<void> saveNote(NoteModel note) async {
    // Implementation using SharedPreferences to save data
  }
}

// Example of Repository managing streams
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesRemoteDataSource? remoteDataSource;
  final NetworkInfo networkInfo;
  final StreamController<List<Note>> _notesStreamController = StreamController<List<Note>>.broadcast();
  
  NotesRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    required this.networkInfo,
  }) {
    // Initialize stream with data
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      final notes = await localDataSource.getNotes();
      _notesStreamController.add(notes);
    } catch (_) {
      // Handle error
    }
  }
  
  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();
      return Right(localNotes);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> saveNote(Note note) async {
    try {
      await localDataSource.saveNote(NoteModel.fromEntity(note));
      
      // Update stream after saving
      final updatedNotes = await localDataSource.getNotes();
      _notesStreamController.add(updatedNotes);
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Stream<List<Note>> notesStream() {
    return _notesStreamController.stream;
  }
}
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│                                                             │
│  ┌─────────────┐       ┌───────────────┐      ┌─────────┐   │
│  │     UI      │◄─────►│  BLoCs/Cubits │◄────►│  States │   │
│  └─────────────┘       └───────────────┘      └─────────┘   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│                                                             │
│  ┌─────────────┐       ┌───────────────┐      ┌─────────┐   │
│  │  Entities   │◄─────►│   Use Cases   │◄────►│ Repos   │   │
│  └─────────────┘       └───────────────┘      │ (Interf)│   │
│                                               └─────────┘   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│                                                             │
│  ┌─────────────┐       ┌───────────────┐      ┌─────────┐   │
│  │   Models    │◄─────►│  Repositories │◄────►│  Data   │   │
│  └─────────────┘       │     (Impl)    │      │ Sources │   │
│                        └───────────────┘      └─────────┘   │
│                                                             │
│  ┌────────────────────┐      ┌─────────────────────────┐    │
│  │ SharedPreferences  │◄────►│ Remote Data Source API  │    │
│  │  (Default Storage) │      │   (Optional Sync)       │    │
│  └────────────────────┘      └─────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Injection

Gradus uses the `get_it` package for dependency injection, ensuring:

- Loose coupling between components
- Easy mocking for tests
- Centralized dependency management

```dart
final serviceLocator = GetIt.instance;

void setupDependencies() {
  // BLoCs/Cubits
  serviceLocator.registerFactory(() => NotesCubit(
    getNotesUseCase: serviceLocator(),
    saveNoteUseCase: serviceLocator(),
  ));
  
  // Use Cases
  serviceLocator.registerLazySingleton(() => GetNotes(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SaveNote(serviceLocator()));
  
  // Repositories
  serviceLocator.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(
    localDataSource: serviceLocator(),
    remoteDataSource: serviceLocator(),
    networkInfo: serviceLocator(),
  ));
  
  // Data Sources
  serviceLocator.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sharedPreferences: serviceLocator())
  );
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
}
```

This architecture ensures that Gradus remains maintainable, testable, and scalable as the application grows and evolves.
