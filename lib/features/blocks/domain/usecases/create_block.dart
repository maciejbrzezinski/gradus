import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for creating new block
/// US-005: Use Cases (Domain Layer)
class CreateBlock {
  final BlockRepository repository;

  CreateBlock(this.repository);

  /// Creates new block with business validation
  Future<void> call(Block block) async {
    // Business validation
    if (block.id.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    if (block.type.isEmpty) {
      throw ArgumentError('Block type cannot be empty');
    }

    // Check if block already exists
    final existingBlock = await repository.getBlock(block.id);
    if (existingBlock != null) {
      throw StateError('Block with ID ${block.id} already exists');
    }

    // Ownership validation - block must belong to either project or date
    if (block.projectId == null && block.date == null) {
      throw ArgumentError('Block must belong to either a project or a specific date');
    }

    // Create block
    await repository.createBlock(block);
  }
}
