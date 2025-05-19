# Gradus - Clean Architecture Implementation

This document outlines how the Gradus application mechanism will be implemented using Clean Architecture principles and the BLoC pattern for state management, as described in the project README.

## Architecture Overview

Gradus follows a Clean Architecture approach with three distinct layers:

1. **Presentation Layer** - UI components and state management
2. **Domain Layer** - Business logic and entities
3. **Data Layer** - Data access and storage

This separation ensures that the application is maintainable, testable, and scalable.

## Mapping Application Mechanism to Clean Architecture

### 1. Domain Layer

The domain layer will contain the core business entities and use cases for the application.

#### Entities

```dart
// lib/domain/entities/block.dart
abstract class Block {
  final String id;
  final BlockType type;
  final dynamic content;
  final Map<String, dynamic> metadata;
  final List<Block> children;
  
  const Block({
    required this.id,
    required this.type,
    required this.content,
    required this.metadata,
    required this.children,
  });
}

// lib/domain/entities/block_types.dart
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

// lib/domain/entities/text_block.dart
class TextBlock extends Block {
  final TextFormatting formatting;
  
  const TextBlock({
    required String id,
    required dynamic content,
    required this.formatting,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) : super(
    id: id,
    type: BlockType.text,
    content: content,
    metadata: metadata ?? const {},
    children: children ?? const [],
  );
}

// lib/domain/entities/todo_block.dart
class TodoBlock extends Block {
  final bool completed;
  final DateTime? dueDate;
  final RepetitionRule? repetition;
  
  const TodoBlock({
    required String id,
    required dynamic content,
    required this.completed,
    this.dueDate,
    this.repetition,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) : super(
    id: id,
    type: BlockType.todo,
    content: content,
    metadata: metadata ?? const {},
    children: children ?? const [],
  );
}

// lib/domain/entities/repetition_rule.dart
class RepetitionRule {
  final RepetitionType type;
  final int interval;
  final List<int> daysOfWeek;
  final int dayOfMonth;
  final DateTime? endDate;
  final int? maxOccurrences;
  
  const RepetitionRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    this.endDate,
    this.maxOccurrences,
  });
}

enum RepetitionType {
  daily,
  weekly,
  monthly,
  custom,
}

// lib/domain/entities/document.dart
class Document {
  final String id;
  final String title;
  final List<Block> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Document({
    required this.id,
    required this.title,
    required this.blocks,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

#### Repository Interfaces

```dart
// lib/domain/repositories/document_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/document.dart';
import '../entities/block.dart';
import '../failures/failures.dart';

abstract class DocumentRepository {
  // Get a document by ID
  Future<Either<Failure, Document>> getDocument(String id);
  
  // Get all documents
  Future<Either<Failure, List<Document>>> getAllDocuments();
  
  // Save a document
  Future<Either<Failure, void>> saveDocument(Document document);
  
  // Delete a document
  Future<Either<Failure, void>> deleteDocument(String id);
  
  // Get a stream of document updates
  Stream<Document> documentStream(String id);
  
  // Get a stream of all documents
  Stream<List<Document>> allDocumentsStream();
}

// lib/domain/repositories/block_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/block.dart';
import '../failures/failures.dart';

abstract class BlockRepository {
  // Create a new block
  Future<Either<Failure, Block>> createBlock(BlockType type, {
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  });
  
  // Update a block
  Future<Either<Failure, void>> updateBlock(Block block);
  
  // Delete a block
  Future<Either<Failure, void>> deleteBlock(String id);
  
  // Convert a block to a different type
  Future<Either<Failure, Block>> convertBlockType(String id, BlockType newType);
}
```

#### Use Cases

```dart
// lib/domain/usecases/get_document.dart
import 'package:dartz/dartz.dart';
import '../repositories/document_repository.dart';
import '../entities/document.dart';
import '../failures/failures.dart';

class GetDocument {
  final DocumentRepository repository;
  
  GetDocument(this.repository);
  
  Future<Either<Failure, Document>> call(String id) {
    return repository.getDocument(id);
  }
}

// lib/domain/usecases/save_document.dart
import 'package:dartz/dartz.dart';
import '../repositories/document_repository.dart';
import '../entities/document.dart';
import '../failures/failures.dart';

class SaveDocument {
  final DocumentRepository repository;
  
  SaveDocument(this.repository);
  
  Future<Either<Failure, void>> call(Document document) {
    return repository.saveDocument(document);
  }
}

// lib/domain/usecases/create_block.dart
import 'package:dartz/dartz.dart';
import '../repositories/block_repository.dart';
import '../entities/block.dart';
import '../failures/failures.dart';

class CreateBlock {
  final BlockRepository repository;
  
  CreateBlock(this.repository);
  
  Future<Either<Failure, Block>> call(BlockType type, {
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) {
    return repository.createBlock(
      type,
      content: content,
      metadata: metadata,
      children: children,
    );
  }
}

// lib/domain/usecases/update_block.dart
import 'package:dartz/dartz.dart';
import '../repositories/block_repository.dart';
import '../entities/block.dart';
import '../failures/failures.dart';

class UpdateBlock {
  final BlockRepository repository;
  
  UpdateBlock(this.repository);
  
  Future<Either<Failure, void>> call(Block block) {
    return repository.updateBlock(block);
  }
}

// lib/domain/usecases/convert_block_type.dart
import 'package:dartz/dartz.dart';
import '../repositories/block_repository.dart';
import '../entities/block.dart';
import '../failures/failures.dart';

class ConvertBlockType {
  final BlockRepository repository;
  
  ConvertBlockType(this.repository);
  
  Future<Either<Failure, Block>> call(String id, BlockType newType) {
    return repository.convertBlockType(id, newType);
  }
}

// lib/domain/usecases/calculate_next_occurrence.dart
import '../entities/repetition_rule.dart';

class CalculateNextOccurrence {
  DateTime call(DateTime currentDate, RepetitionRule rule) {
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
}
```

### 2. Data Layer

The data layer will implement the repository interfaces defined in the domain layer and provide concrete data sources.

#### Models

```dart
// lib/data/models/block_model.dart
import '../../domain/entities/block.dart';

class BlockModel extends Block {
  const BlockModel({
    required String id,
    required BlockType type,
    required dynamic content,
    required Map<String, dynamic> metadata,
    required List<Block> children,
  }) : super(
    id: id,
    type: type,
    content: content,
    metadata: metadata,
    children: children,
  );
  
  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'],
      type: BlockType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      content: json['content'],
      metadata: json['metadata'] ?? {},
      children: (json['children'] as List?)
          ?.map((child) => BlockModel.fromJson(child))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'metadata': metadata,
      'children': children.map((child) => 
        (child as BlockModel).toJson()
      ).toList(),
    };
  }
  
  factory BlockModel.fromEntity(Block block) {
    return BlockModel(
      id: block.id,
      type: block.type,
      content: block.content,
      metadata: block.metadata,
      children: block.children.map((child) => 
        BlockModel.fromEntity(child)
      ).toList(),
    );
  }
}

// lib/data/models/document_model.dart
import '../../domain/entities/document.dart';
import 'block_model.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required String id,
    required String title,
    required List<BlockModel> blocks,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    title: title,
    blocks: blocks,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      title: json['title'],
      blocks: (json['blocks'] as List)
          .map((block) => BlockModel.fromJson(block))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'blocks': blocks.map((block) => 
        (block as BlockModel).toJson()
      ).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      title: document.title,
      blocks: document.blocks.map((block) => 
        BlockModel.fromEntity(block)
      ).toList(),
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    );
  }
}
```

#### Data Sources

```dart
// lib/data/datasources/document_local_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';
import '../../core/error/exceptions.dart';

abstract class DocumentLocalDataSource {
  /// Gets a document by ID from local storage
  Future<DocumentModel> getDocument(String id);
  
  /// Gets all documents from local storage
  Future<List<DocumentModel>> getAllDocuments();
  
  /// Saves a document to local storage
  Future<void> saveDocument(DocumentModel document);
  
  /// Deletes a document from local storage
  Future<void> deleteDocument(String id);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  DocumentLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<DocumentModel> getDocument(String id) async {
    final jsonString = sharedPreferences.getString('document_$id');
    if (jsonString != null) {
      return DocumentModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }
  
  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    final documentIds = sharedPreferences.getStringList('document_ids') ?? [];
    final documents = <DocumentModel>[];
    
    for (final id in documentIds) {
      try {
        final document = await getDocument(id);
        documents.add(document);
      } catch (e) {
        // Skip documents that can't be loaded
      }
    }
    
    return documents;
  }
  
  @override
  Future<void> saveDocument(DocumentModel document) async {
    // Save the document
    await sharedPreferences.setString(
      'document_${document.id}',
      json.encode(document.toJson()),
    );
    
    // Update the list of document IDs
    final documentIds = sharedPreferences.getStringList('document_ids') ?? [];
    if (!documentIds.contains(document.id)) {
      documentIds.add(document.id);
      await sharedPreferences.setStringList('document_ids', documentIds);
    }
  }
  
  @override
  Future<void> deleteDocument(String id) async {
    // Remove the document
    await sharedPreferences.remove('document_$id');
    
    // Update the list of document IDs
    final documentIds = sharedPreferences.getStringList('document_ids') ?? [];
    documentIds.remove(id);
    await sharedPreferences.setStringList('document_ids', documentIds);
  }
}
```

#### Repositories

```dart
// lib/data/repositories/document_repository_impl.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/entities/document.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/document_local_data_source.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource localDataSource;
  final StreamController<Document> _documentStreamController = StreamController<Document>.broadcast();
  final StreamController<List<Document>> _allDocumentsStreamController = StreamController<List<Document>>.broadcast();
  
  DocumentRepositoryImpl({
    required this.localDataSource,
  }) {
    // Initialize streams with data
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      final documents = await localDataSource.getAllDocuments();
      _allDocumentsStreamController.add(documents);
    } catch (_) {
      // Handle error
    }
  }
  
  @override
  Future<Either<Failure, Document>> getDocument(String id) async {
    try {
      final documentModel = await localDataSource.getDocument(id);
      return Right(documentModel);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, List<Document>>> getAllDocuments() async {
    try {
      final documentModels = await localDataSource.getAllDocuments();
      return Right(documentModels);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> saveDocument(Document document) async {
    try {
      await localDataSource.saveDocument(
        DocumentModel.fromEntity(document),
      );
      
      // Update streams
      _documentStreamController.add(document);
      final documents = await localDataSource.getAllDocuments();
      _allDocumentsStreamController.add(documents);
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      await localDataSource.deleteDocument(id);
      
      // Update streams
      final documents = await localDataSource.getAllDocuments();
      _allDocumentsStreamController.add(documents);
      
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Stream<Document> documentStream(String id) {
    // Filter the stream to only emit documents with the given ID
    return _documentStreamController.stream
        .where((document) => document.id == id);
  }
  
  @override
  Stream<List<Document>> allDocumentsStream() {
    return _allDocumentsStreamController.stream;
  }
}

// lib/data/repositories/block_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/block_repository.dart';
import '../../domain/entities/block.dart';
import '../../core/error/failures.dart';
import '../models/block_model.dart';

class BlockRepositoryImpl implements BlockRepository {
  @override
  Future<Either<Failure, Block>> createBlock(BlockType type, {
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) async {
    try {
      final block = BlockModel(
        id: const Uuid().v4(),
        type: type,
        content: content ?? '',
        metadata: metadata ?? {},
        children: children ?? [],
      );
      
      return Right(block);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> updateBlock(Block block) async {
    try {
      // In a real implementation, this would update the block in storage
      // For now, we just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteBlock(String id) async {
    try {
      // In a real implementation, this would delete the block from storage
      // For now, we just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
  
  @override
  Future<Either<Failure, Block>> convertBlockType(String id, BlockType newType) async {
    try {
      // In a real implementation, this would convert the block in storage
      // For now, we just return a new block with the new type
      final block = BlockModel(
        id: id,
        type: newType,
        content: '',
        metadata: {},
        children: [],
      );
      
      return Right(block);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

### 3. Presentation Layer

The presentation layer will contain the UI components and state management using the BLoC pattern.

#### BLoCs/Cubits

```dart
// lib/presentation/bloc/document/document_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/document.dart';
import '../../../domain/usecases/get_document.dart';
import '../../../domain/usecases/save_document.dart';

// States
abstract class DocumentState extends Equatable {
  const DocumentState();
  
  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final Document document;
  
  const DocumentLoaded({required this.document});
  
  @override
  List<Object?> get props => [document];
}

class DocumentError extends DocumentState {
  final String message;
  
  const DocumentError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class DocumentCubit extends Cubit<DocumentState> {
  final GetDocument getDocument;
  final SaveDocument saveDocument;
  
  DocumentCubit({
    required this.getDocument,
    required this.saveDocument,
  }) : super(DocumentInitial());
  
  Future<void> loadDocument(String id) async {
    emit(DocumentLoading());
    
    final result = await getDocument(id);
    
    result.fold(
      (failure) => emit(DocumentError(message: failure.message)),
      (document) => emit(DocumentLoaded(document: document)),
    );
  }
  
  Future<void> updateDocument(Document document) async {
    final currentState = state;
    
    if (currentState is DocumentLoaded) {
      emit(DocumentLoading());
      
      final result = await saveDocument(document);
      
      result.fold(
        (failure) => emit(DocumentError(message: failure.message)),
        (_) => emit(DocumentLoaded(document: document)),
      );
    }
  }
}

// lib/presentation/bloc/block/block_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/block.dart';
import '../../../domain/usecases/create_block.dart';
import '../../../domain/usecases/update_block.dart';
import '../../../domain/usecases/convert_block_type.dart';

// States
abstract class BlockState extends Equatable {
  const BlockState();
  
  @override
  List<Object?> get props => [];
}

class BlockInitial extends BlockState {}

class BlockLoading extends BlockState {}

class BlockLoaded extends BlockState {
  final Block block;
  
  const BlockLoaded({required this.block});
  
  @override
  List<Object?> get props => [block];
}

class BlockError extends BlockState {
  final String message;
  
  const BlockError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class BlockCubit extends Cubit<BlockState> {
  final CreateBlock createBlock;
  final UpdateBlock updateBlock;
  final ConvertBlockType convertBlockType;
  
  BlockCubit({
    required this.createBlock,
    required this.updateBlock,
    required this.convertBlockType,
  }) : super(BlockInitial());
  
  Future<void> createNewBlock(BlockType type, {
    dynamic content,
    Map<String, dynamic>? metadata,
    List<Block>? children,
  }) async {
    emit(BlockLoading());
    
    final result = await createBlock(
      type,
      content: content,
      metadata: metadata,
      children: children,
    );
    
    result.fold(
      (failure) => emit(BlockError(message: failure.message)),
      (block) => emit(BlockLoaded(block: block)),
    );
  }
  
  Future<void> updateExistingBlock(Block block) async {
    emit(BlockLoading());
    
    final result = await updateBlock(block);
    
    result.fold(
      (failure) => emit(BlockError(message: failure.message)),
      (_) => emit(BlockLoaded(block: block)),
    );
  }
  
  Future<void> convertBlock(String id, BlockType newType) async {
    emit(BlockLoading());
    
    final result = await convertBlockType(id, newType);
    
    result.fold(
      (failure) => emit(BlockError(message: failure.message)),
      (block) => emit(BlockLoaded(block: block)),
    );
  }
}

// lib/presentation/bloc/command_palette/command_palette_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/block.dart';

// States
abstract class CommandPaletteState extends Equatable {
  const CommandPaletteState();
  
  @override
  List<Object?> get props => [];
}

class CommandPaletteHidden extends CommandPaletteState {}

class CommandPaletteVisible extends CommandPaletteState {
  final Offset position;
  final String query;
  final List<BlockType> filteredTypes;
  final int selectedIndex;
  
  const CommandPaletteVisible({
    required this.position,
    this.query = '',
    required this.filteredTypes,
    this.selectedIndex = 0,
  });
  
  @override
  List<Object?> get props => [position, query, filteredTypes, selectedIndex];
}

// Cubit
class CommandPaletteCubit extends Cubit<CommandPaletteState> {
  final List<BlockType> allBlockTypes = BlockType.values;
  
  CommandPaletteCubit() : super(CommandPaletteHidden());
  
  void showCommandPalette(Offset position) {
    emit(CommandPaletteVisible(
      position: position,
      filteredTypes: allBlockTypes,
    ));
  }
  
  void hideCommandPalette() {
    emit(CommandPaletteHidden());
  }
  
  void updateQuery(String query) {
    final currentState = state;
    
    if (currentState is CommandPaletteVisible) {
      final filteredTypes = allBlockTypes.where((type) {
        final typeName = type.toString().split('.').last;
        return typeName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      emit(CommandPaletteVisible(
        position: currentState.position,
        query: query,
        filteredTypes: filteredTypes,
        selectedIndex: 0,
      ));
    }
  }
  
  void selectNextOption() {
    final currentState = state;
    
    if (currentState is CommandPaletteVisible) {
      final selectedIndex = (currentState.selectedIndex + 1) % currentState.filteredTypes.length;
      
      emit(CommandPaletteVisible(
        position: currentState.position,
        query: currentState.query,
        filteredTypes: currentState.filteredTypes,
        selectedIndex: selectedIndex,
      ));
    }
  }
  
  void selectPreviousOption() {
    final currentState = state;
    
    if (currentState is CommandPaletteVisible) {
      final selectedIndex = (currentState.selectedIndex - 1 + currentState.filteredTypes.length) % currentState.filteredTypes.length;
      
      emit(CommandPaletteVisible(
        position: currentState.position,
        query: currentState.query,
        filteredTypes: currentState.filteredTypes,
        selectedIndex: selectedIndex,
      ));
    }
  }
  
  BlockType? getSelectedType() {
    final currentState = state;
    
    if (currentState is CommandPaletteVisible && currentState.filteredTypes.isNotEmpty) {
      return currentState.filteredTypes[currentState.selectedIndex];
    }
    
    return null;
  }
}
```

#### UI Components

```dart
// lib/presentation/widgets/block_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/block.dart';
import '../bloc/block/block_cubit.dart';
import '../bloc/command_palette/command_palette_cubit.dart';

abstract class BlockWidget extends StatefulWidget {
  final Block block;
  final FocusNode focusNode;
  final bool isSelected;
  final VoidCallback? onFocusChange;
  
  const BlockWidget({
    Key? key,
    required this.block,
    required this.focusNode,
    this.isSelected = false,
    this.onFocusChange,
  }) : super(key: key);
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
      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      
      context.read<CommandPaletteCubit>().showCommandPalette(position);
    }
    
    // Check for empty content with backspace
    if (textController.text.isEmpty && _isBackspacePressed()) {
      deleteBlock();
    }
  }
  
  bool _isBackspacePressed() {
    // Implementation would check if backspace was pressed
    return false;
  }
  
  String getBlockContent();
  
  void updateBlockContent(String content);
  
  void deleteBlock() {
