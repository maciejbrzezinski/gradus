import '../entities/block.dart';
import '../repositories/block_repository.dart';

/// Use Case do aktualizacji istniejącego bloku
/// US-005: Use Cases (Domain Layer)
class UpdateBlock {
  final BlockRepository repository;

  UpdateBlock(this.repository);

  /// Aktualizuje istniejący blok z walidacją biznesową
  Future<void> call(Block block) async {
    // Walidacja biznesowa
    if (block.id.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    if (block.type.isEmpty) {
      throw ArgumentError('Block type cannot be empty');
    }

    // Sprawdzenie czy blok istnieje
    final existingBlock = await repository.getBlock(block.id);
    if (existingBlock == null) {
      throw StateError('Block with ID ${block.id} does not exist');
    }

    // Walidacja przynależności - blok musi należeć do projektu lub daty
    if (block.projectId == null && block.date == null) {
      throw ArgumentError('Block must belong to either a project or a specific date');
    }

    // Aktualizacja bloku
    await repository.updateBlock(block);
  }
}
