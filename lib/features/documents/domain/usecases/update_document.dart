import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for updating existing document
/// US-005: Use Cases (Domain Layer)
class UpdateDocument {
  final DocumentRepository repository;

  UpdateDocument(this.repository);

  /// Updates existing document with business validation
  Future<void> call(Document document) async {
    // Business validation
    if (document.id.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Check if document exists
    final existingDocument = await repository.getDocument(document.id);
    if (existingDocument == null) {
      throw StateError('Document with ID ${document.id} does not exist');
    }

    // Validation for timeline vs project documents
    if (document.date != null && document.title != null) {
      throw ArgumentError('Document cannot be both timeline (date) and project (title) at the same time');
    }

    // Validation for project documents (must have title)
    if (document.date == null && document.title == null) {
      throw ArgumentError('Document must be either timeline (with date) or project (with title)');
    }

    // Update document
    await repository.updateDocument(document);
  }
}
