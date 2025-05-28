import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for getting all blocks for specific document
/// US-005: Use Cases (Domain Layer)
class GetBlocksByDocument {
  final BlockRepository repository;

  GetBlocksByDocument(this.repository);

  /// Gets all blocks for specific document
  Future<List<Block>> call(String documentId) async {
    // Business validation
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be empty');
    }

    return await repository.getBlocksByDocument(documentId);
  }
}
