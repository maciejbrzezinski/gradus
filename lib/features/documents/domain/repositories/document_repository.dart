import '../entities/document.dart';

/// Repository interface for document operations
/// US-004: Repository interfaces (Domain Layer)
abstract class DocumentRepository {
  /// Gets document by ID
  Future<Document?> getDocument(String id);

  /// Gets all documents
  Future<List<Document>> getAllDocuments();

  /// Gets document for specific date (timeline)
  Future<Document?> getDocumentByDate(DateTime date);

  /// Gets documents in date range (lazy loading for timeline)
  Future<List<Document>> getDocumentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets all project documents
  Future<List<Document>> getProjectDocuments();

  /// Gets project timeline documents in date range
  Future<List<Document>> getProjectTimelineDocuments(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Creates new document
  Future<void> createDocument(Document document);

  /// Updates existing document
  Future<void> updateDocument(Document document);

  /// Deletes document
  Future<void> deleteDocument(String id);

  /// Watches document changes (real-time updates)
  Stream<List<Document>> watchDocuments();
}
