import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for watching block changes in specific document (real-time updates)
/// US-005: Use Cases (Domain Layer)
class WatchBlocksByDocument {
  final BlockRepository repository;

  WatchBlocksByDocument(this.repository);

  /// Watches block changes in specific document and returns a stream
  Stream<List<Block>> call(String documentId) {
    // Business validation
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    return repository.watchBlocksByDocument(documentId);
  }
}
