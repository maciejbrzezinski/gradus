import '../repositories/block_repository.dart';

/// Use Case do usuwania bloku
/// US-005: Use Cases (Domain Layer)
class DeleteBlock {
  final BlockRepository repository;

  DeleteBlock(this.repository);

  /// Usuwa blok z walidacją biznesową
  Future<void> call(String blockId) async {
    // Walidacja biznesowa
    if (blockId.isEmpty) {
      throw ArgumentError('Block ID cannot be empty');
    }

    // Sprawdzenie czy blok istnieje
    final existingBlock = await repository.getBlock(blockId);
    if (existingBlock == null) {
      throw StateError('Block with ID $blockId does not exist');
    }

    // W przyszłości można dodać sprawdzenie czy blok nie ma dzieci
    // lub automatyczne usuwanie powiązanych bloków potomnych

    // Usunięcie bloku
    await repository.deleteBlock(blockId);
  }
}
