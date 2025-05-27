import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for getting document by ID
/// US-005: Use Cases (Domain Layer)
class GetDocument {
  final DocumentRepository repository;

  GetDocument(this.repository);

  /// Gets document by ID with business validation
  Future<Document?> call(String documentId) async {
    // Business validation
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Get document
    return await repository.getDocument(documentId);
  }
}
