import '../entities/block.dart';

/// Repository interface for block operations
/// US-004: Repository interfaces (Domain Layer)
abstract class BlockRepository {
  /// Gets block by ID
  Future<Block?> getBlock(String id);

  /// Gets all blocks for specific document
  Future<List<Block>> getBlocksByDocument(String documentId);

  /// Gets blocks for multiple documents at once (batch loading)
  /// Returns map: documentId -> list of blocks
  Future<Map<String, List<Block>>> getBlocksByDocuments(
    List<String> documentIds,
  );

  /// Creates new block
  Future<void> createBlock(Block block);

  /// Updates existing block
  Future<void> updateBlock(Block block);

  /// Deletes block
  Future<void> deleteBlock(String id);

  /// Changes block order in document (drag & drop)
  Future<void> reorderBlocks(String documentId, List<String> blockIds);

  /// Watches block changes in specific document (real-time updates)
  Stream<List<Block>> watchBlocksByDocument(String documentId);
}
