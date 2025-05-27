import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case do aktualizacji istniejącego dokumentu
/// US-005: Use Cases (Domain Layer)
class UpdateDocument {
  final DocumentRepository repository;

  UpdateDocument(this.repository);

  /// Aktualizuje istniejący dokument z walidacją biznesową
  Future<void> call(Document document) async {
    // Walidacja biznesowa
    if (document.id.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    // Sprawdzenie czy dokument istnieje
    final existingDocument = await repository.getDocument(document.id);
    if (existingDocument == null) {
      throw StateError('Document with ID ${document.id} does not exist');
    }

    // Walidacja dla dokumentów timeline vs project
    if (document.date != null && document.title != null) {
      throw ArgumentError('Document cannot be both timeline (date) and project (title) at the same time');
    }

    // Walidacja dla dokumentów projektów (muszą mieć tytuł)
    if (document.date == null && document.title == null) {
      throw ArgumentError('Document must be either timeline (with date) or project (with title)');
    }

    // Aktualizacja dokumentu
    await repository.updateDocument(document);
  }
}
