import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case do pobierania dokumentu po ID
/// US-005: Use Cases (Domain Layer)
class GetDocument {
  final DocumentRepository repository;

  GetDocument(this.repository);

  /// Pobiera dokument po ID z walidacją biznesową
  Future<Document?> call(String documentId) async {
    // Walidacja biznesowa
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Pobranie dokumentu
    return await repository.getDocument(documentId);
  }
}
