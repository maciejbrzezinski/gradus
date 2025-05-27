import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for creating new document
/// US-005: Use Cases (Domain Layer)
class CreateDocument {
  final DocumentRepository repository;

  CreateDocument(this.repository);

  /// Creates new document with business validation
  Future<void> call(Document document) async {
    // Business validation
    if (document.id.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Check if document already exists
    final existingDocument = await repository.getDocument(document.id);
    if (existingDocument != null) {
      throw StateError('Document with ID ${document.id} already exists');
    }

    // Validation for project documents (must have title)
    if (document.date == null && document.title == null) {
      throw ArgumentError('Document must be either timeline (with date) or project (with title) or both');
    }

    // Create document
    await repository.createDocument(document);
  }
}
