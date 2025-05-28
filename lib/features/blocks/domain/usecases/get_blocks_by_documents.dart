import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for getting blocks for multiple documents (batch loading)
/// US-005: Use Cases (Domain Layer)
class GetBlocksByDocuments {
  final BlockRepository repository;

  GetBlocksByDocuments(this.repository);

  /// Gets blocks for multiple documents at once (batch loading)
  /// Returns map: documentId -> list of blocks
  Future<Map<String, List<Block>>> call(List<String> documentIds) async {
    // Business validation
    if (documentIds.isEmpty) {
      throw ArgumentError('Document IDs list cannot be empty');
    }

    for (final id in documentIds) {
      if (id.isEmpty) {
        throw ArgumentError('Document ID cannot be empty');
      }
    }

    return await repository.getBlocksByDocuments(documentIds);
  }
}
