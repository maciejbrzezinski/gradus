import '../repositories/document_repository.dart';

/// Use Case for deleting document
/// US-005: Use Cases (Domain Layer)
class DeleteDocument {
  final DocumentRepository repository;

  DeleteDocument(this.repository);

  /// Deletes document with business validation
  Future<void> call(String documentId) async {
    // Business validation
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Check if document exists
    final existingDocument = await repository.getDocument(documentId);
    if (existingDocument == null) {
      throw StateError('Document with ID $documentId does not exist');
    }

    // Check if document has no blocks (optional business validation)
    // In the future, can add check if document contains no blocks
    // or automatic deletion of related blocks

    // Delete document
    await repository.deleteDocument(documentId);
  }
}
