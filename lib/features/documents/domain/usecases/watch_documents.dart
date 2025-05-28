import '../entities/document.dart';
import '../repositories/document_repository.dart';

/// Use Case for watching document changes (real-time updates)
/// US-005: Use Cases (Domain Layer)
class WatchDocuments {
  final DocumentRepository repository;

  WatchDocuments(this.repository);

  /// Watches document changes and returns a stream
  Stream<List<Document>> call() {
    return repository.watchDocuments();
  }
}
