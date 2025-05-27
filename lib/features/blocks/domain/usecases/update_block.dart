import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for updating existing block
/// US-005: Use Cases (Domain Layer)
class UpdateBlock {
  final BlockRepository repository;

  UpdateBlock(this.repository);

  /// Updates existing block with business validation
  Future<void> call(Block block) async {
    // Business validation
    if (block.id.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    if (block.type.isEmpty) {
      throw ArgumentError('Block type cannot be empty');
    }

    // Check if block exists
    final existingBlock = await repository.getBlock(block.id);
    if (existingBlock == null) {
      throw StateError('Block with ID ${block.id} does not exist');
    }

    // Ownership validation - block must belong to either project or date
    if (block.projectId == null && block.date == null) {
      throw ArgumentError('Block must belong to either a project or a specific date');
    }

    // Update block
    await repository.updateBlock(block);
  }
}
