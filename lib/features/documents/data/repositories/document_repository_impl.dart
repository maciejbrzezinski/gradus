import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document.model.dart';
import '../../../../brick/repository.dart';
import 'package:brick_core/query.dart';

/// Document repository implementation using Brick
/// US-007: SQLite configuration with Brick
class DocumentRepositoryImpl implements DocumentRepository {
  final Repository _repository;

  DocumentRepositoryImpl(this._repository);

  @override
  Future<List<Document>> getAllDocuments() async {
    final models = await _repository.get<DocumentModel>();
    return models.map(_mapToEntity).toList();
  }

  @override
  Future<Document?> getDocument(String id) async {
    final models = await _repository.get<DocumentModel>(
      query: Query.where('id', id),
    );
    if (models.isEmpty) return null;
    return _mapToEntity(models.first);
  }

  @override
  Future<Document?> getDocumentByDate(DateTime date) async {
    final models = await _repository.get<DocumentModel>(
      query: Query.where('date', date),
    );
    if (models.isEmpty) return null;
    return _mapToEntity(models.first);
  }

  @override
  Future<List<Document>> getDocumentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // For now, get all documents and filter in memory
    // TODO: Implement proper date range query in Brick
    final models = await _repository.get<DocumentModel>();
    return models
        .where((model) => 
            model.date != null &&
            model.date!.isAfter(startDate.subtract(const Duration(days: 1))) &&
            model.date!.isBefore(endDate.add(const Duration(days: 1))))
        .map(_mapToEntity)
        .toList();
  }

  @override
  Future<List<Document>> getProjectTimelineDocuments(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Get project documents with dates in range
    final models = await _repository.get<DocumentModel>();
    return models
        .where((model) => 
            model.title != null && // Project documents have titles
            model.date != null &&
            model.date!.isAfter(startDate.subtract(const Duration(days: 1))) &&
            model.date!.isBefore(endDate.add(const Duration(days: 1))))
        .map(_mapToEntity)
        .toList();
  }

  @override
  Stream<List<Document>> watchDocuments() {
    // TODO: Implement real-time streaming with Brick
    return Stream.fromFuture(getAllDocuments());
  }

  @override
  Future<List<Document>> getProjectDocuments() async {
    final models = await _repository.get<DocumentModel>(
      query: Query.where('date', null),
    );
    return models.map(_mapToEntity).toList();
  }

  @override
  Future<void> createDocument(Document document) async {
    final model = _mapToModel(document);
    await _repository.upsert<DocumentModel>(model);
  }

  @override
  Future<void> updateDocument(Document document) async {
    final model = _mapToModel(document);
    await _repository.upsert<DocumentModel>(model);
  }

  @override
  Future<void> deleteDocument(String id) async {
    final models = await _repository.get<DocumentModel>(
      query: Query.where('id', id),
    );
    if (models.isNotEmpty) {
      await _repository.delete<DocumentModel>(models.first);
    }
  }

  Document _mapToEntity(DocumentModel model) {
    return Document(
      id: model.id,
      date: model.date,
      title: model.title,
      icon: model.icon,
      iconColor: model.iconColor,
      blocks: model.blocks,
    );
  }

  DocumentModel _mapToModel(Document entity) {
    return DocumentModel(
      id: entity.id,
      date: entity.date,
      title: entity.title,
      icon: entity.icon,
      iconColor: entity.iconColor,
      blocks: entity.blocks,
    );
  }
}
