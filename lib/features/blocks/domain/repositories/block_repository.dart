import '../entities/block.dart';

/// Repository interface dla operacji na blokach
/// US-004: Repository interfaces (Domain Layer)
abstract class BlockRepository {
  /// Pobiera blok po ID
  Future<Block?> getBlock(String id);

  /// Pobiera wszystkie bloki dla konkretnego dokumentu
  Future<List<Block>> getBlocksByDocument(String documentId);

  /// Pobiera bloki dla wielu dokumentów jednocześnie (batch loading)
  /// Zwraca mapę: documentId -> lista bloków
  Future<Map<String, List<Block>>> getBlocksByDocuments(
    List<String> documentIds,
  );

  /// Tworzy nowy blok
  Future<void> createBlock(Block block);

  /// Aktualizuje istniejący blok
  Future<void> updateBlock(Block block);

  /// Usuwa blok
  Future<void> deleteBlock(String id);

  /// Zmienia kolejność bloków w dokumencie (drag & drop)
  Future<void> reorderBlocks(String documentId, List<String> blockIds);

  /// Obserwuje zmiany bloków w konkretnym dokumencie (real-time updates)
  Stream<List<Block>> watchBlocksByDocument(String documentId);
}
