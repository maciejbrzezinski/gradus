import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

// Core
import '../../brick/repository.dart';

// Document Repository & Implementations
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/documents/data/repositories/document_repository_impl.dart';

// Block Repository & Implementations
import '../../features/blocks/domain/repositories/block_repository.dart';
import '../../features/blocks/data/repositories/block_repository_impl.dart';

// Document Use Cases
import '../../features/documents/domain/usecases/create_document.dart';
import '../../features/documents/domain/usecases/update_document.dart';
import '../../features/documents/domain/usecases/delete_document.dart';
import '../../features/documents/domain/usecases/get_document.dart';
import '../../features/documents/domain/usecases/get_all_documents.dart';
import '../../features/documents/domain/usecases/get_document_by_date.dart';
import '../../features/documents/domain/usecases/get_documents_by_date_range.dart';
import '../../features/documents/domain/usecases/get_project_documents.dart';
import '../../features/documents/domain/usecases/get_project_timeline_documents.dart';
import '../../features/documents/domain/usecases/watch_documents.dart';

// Block Use Cases
import '../../features/blocks/domain/usecases/create_block.dart';
import '../../features/blocks/domain/usecases/update_block.dart';
import '../../features/blocks/domain/usecases/delete_block.dart';
import '../../features/blocks/domain/usecases/get_block.dart';
import '../../features/blocks/domain/usecases/get_blocks_by_document.dart';
import '../../features/blocks/domain/usecases/get_blocks_by_documents.dart';
import '../../features/blocks/domain/usecases/reorder_blocks.dart';
import '../../features/blocks/domain/usecases/watch_blocks_by_document.dart';

/// Service Locator for Dependency Injection
/// GetIt configuration according to Clean Architecture
final getIt = GetIt.instance;

/// Initialize all dependencies
/// US-006: Dependency Injection setup
Future<void> initializeDependencies() async {
  try {
    // 1. Core Services
    await _registerCoreServices();
    
    // 2. Data Layer (Repository Implementations)
    _registerRepositories();
    
    // 3. Domain Layer (Use Cases)
    _registerUseCases();
    
    // 4. Presentation Layer (BLoCs/Cubits - future)
    _registerBlocs();
    
    print('✓ Dependency Injection initialized successfully');
  } catch (e) {
    print('✗ Failed to initialize dependencies: $e');
    rethrow;
  }
}

/// Register core services (Brick Repository)
Future<void> _registerCoreServices() async {
  // Register Brick Repository as singleton
  getIt.registerSingletonAsync<Repository>(() async {
    await Repository.configure(databaseFactory);
    return Repository();
  });
  
  // Wait for Repository to be ready
  await getIt.isReady<Repository>();
}

/// Register repository implementations
void _registerRepositories() {
  // Document Repository
  getIt.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(getIt<Repository>()),
  );
  
  // Block Repository
  getIt.registerLazySingleton<BlockRepository>(
    () => BlockRepositoryImpl(getIt<Repository>()),
  );
}

/// Register all use cases
void _registerUseCases() {
  // Document Use Cases
  _registerDocumentUseCases();
  
  // Block Use Cases
  _registerBlockUseCases();
}

/// Register document use cases
void _registerDocumentUseCases() {
  // CRUD Operations
  getIt.registerLazySingleton(() => CreateDocument(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => UpdateDocument(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => DeleteDocument(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => GetDocument(getIt<DocumentRepository>()));
  
  // Query Operations
  getIt.registerLazySingleton(() => GetAllDocuments(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => GetDocumentByDate(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => GetDocumentsByDateRange(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => GetProjectDocuments(getIt<DocumentRepository>()));
  getIt.registerLazySingleton(() => GetProjectTimelineDocuments(getIt<DocumentRepository>()));
  
  // Real-time Operations
  getIt.registerLazySingleton(() => WatchDocuments(getIt<DocumentRepository>()));
}

/// Register block use cases
void _registerBlockUseCases() {
  // CRUD Operations
  getIt.registerLazySingleton(() => CreateBlock(getIt<BlockRepository>()));
  getIt.registerLazySingleton(() => UpdateBlock(getIt<BlockRepository>()));
  getIt.registerLazySingleton(() => DeleteBlock(getIt<BlockRepository>()));
  getIt.registerLazySingleton(() => GetBlock(getIt<BlockRepository>()));
  
  // Query Operations
  getIt.registerLazySingleton(() => GetBlocksByDocument(getIt<BlockRepository>()));
  getIt.registerLazySingleton(() => GetBlocksByDocuments(getIt<BlockRepository>()));
  
  // Management Operations
  getIt.registerLazySingleton(() => ReorderBlocks(getIt<BlockRepository>()));
  
  // Real-time Operations
  getIt.registerLazySingleton(() => WatchBlocksByDocument(getIt<BlockRepository>()));
}

/// Register BLoCs and Cubits (future implementations)
void _registerBlocs() {
  // TODO: Register cubits and blocs when they are implemented
  // Examples:
  // getIt.registerFactory(() => DocumentCubit(getIt<CreateDocument>(), getIt<UpdateDocument>(), ...));
  // getIt.registerFactory(() => BlockCubit(getIt<CreateBlock>(), getIt<UpdateBlock>(), ...));
  // getIt.registerFactory(() => CommandPaletteCubit());
}
