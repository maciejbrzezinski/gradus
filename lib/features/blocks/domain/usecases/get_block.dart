import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case for getting block by ID
/// US-005: Use Cases (Domain Layer)
class GetBlock {
  final BlockRepository repository;

  GetBlock(this.repository);

  /// Gets block by ID
  Future<Block?> call(String id) async {
    // Business validation
    if (id.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    return await repository.getBlock(id);
  }
}
