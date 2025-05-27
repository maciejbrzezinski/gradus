import '../repositories/block_repository.dart';

/// Use Case for deleting block
/// US-005: Use Cases (Domain Layer)
class DeleteBlock {
  final BlockRepository repository;

  DeleteBlock(this.repository);

  /// Deletes block with business validation
  Future<void> call(String blockId) async {
    // Business validation
    if (blockId.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    // Check if block exists
    final existingBlock = await repository.getBlock(blockId);
    if (existingBlock == null) {
      throw StateError('Block with ID $blockId does not exist');
    }

    // In the future, can add check if block has no children
    // or automatic deletion of related child blocks

    // Delete block
    await repository.deleteBlock(blockId);
  }
}
