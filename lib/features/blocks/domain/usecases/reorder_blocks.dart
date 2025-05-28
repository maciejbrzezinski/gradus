import '../repositories/block_repository.dart';

/// Use Case for reordering blocks in document (drag & drop)
/// US-005: Use Cases (Domain Layer)
class ReorderBlocks {
  final BlockRepository repository;

  ReorderBlocks(this.repository);

  /// Changes block order in document (drag & drop)
  Future<void> call(String documentId, List<String> blockIds) async {
    // Business validation
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    if (blockIds.isEmpty) {
      throw ArgumentError('Block IDs list cannot be empty');
    }

    for (final id in blockIds) {
      if (id.isEmpty) {
        throw ArgumentError('Block ID cannot be empty');
      }
    }

    return await repository.reorderBlocks(documentId, blockIds);
  }
}
