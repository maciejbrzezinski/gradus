import '../repositories/document_repository.dart';

/// Use Case do usuwania dokumentu
/// US-005: Use Cases (Domain Layer)
class DeleteDocument {
  final DocumentRepository repository;

  DeleteDocument(this.repository);

  /// Usuwa dokument z walidacją biznesową
  Future<void> call(String documentId) async {
    // Walidacja biznesowa
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Sprawdzenie czy dokument istnieje
    final existingDocument = await repository.getDocument(documentId);
    if (existingDocument == null) {
      throw StateError('Document with ID $documentId does not exist');
    }

    // Sprawdzenie czy dokument nie ma bloków (opcjonalna walidacja biznesowa)
    // W przyszłości można dodać sprawdzenie czy dokument nie zawiera bloków
    // lub automatyczne usuwanie powiązanych bloków

    // Usunięcie dokumentu
    await repository.deleteDocument(documentId);
  }
}
