import '../entities/document.dart';

/// Repository interface dla operacji na dokumentach
/// US-004: Repository interfaces (Domain Layer)
abstract class DocumentRepository {
  /// Pobiera dokument po ID
  Future<Document?> getDocument(String id);

  /// Pobiera wszystkie dokumenty
  Future<List<Document>> getAllDocuments();

  /// Pobiera dokument dla konkretnej daty (timeline)
  Future<Document?> getDocumentByDate(DateTime date);

  /// Pobiera dokumenty w zakresie dat (lazy loading dla timeline)
  Future<List<Document>> getDocumentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Pobiera wszystkie dokumenty projektów
  Future<List<Document>> getProjectDocuments();

  /// Pobiera dokumenty timeline dla konkretnego projektu w zakresie dat
  Future<List<Document>> getProjectTimelineDocuments(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Tworzy nowy dokument
  Future<void> createDocument(Document document);

  /// Aktualizuje istniejący dokument
  Future<void> updateDocument(Document document);

  /// Usuwa dokument
  Future<void> deleteDocument(String id);

  /// Obserwuje zmiany w dokumentach (real-time updates)
  Stream<List<Document>> watchDocuments();
}
