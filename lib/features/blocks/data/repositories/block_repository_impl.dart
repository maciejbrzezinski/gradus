import '../../domain/entities/block.dart';
import '../../domain/repositories/block_repository.dart';
import '../models/block.model.dart';
import '../../../../brick/repository.dart';
import 'package:brick_core/query.dart';

/// Block repository implementation using Brick
/// US-007: SQLite configuration with Brick
class BlockRepositoryImpl implements BlockRepository {
  final Repository _repository;

  BlockRepositoryImpl(this._repository);

  @override
  Future<Block?> getBlock(String id) async {
    final models = await _repository.get<BlockModel>(
      query: Query.where('id', id),
    );
    if (models.isEmpty) return null;
    
    // Load children for this block
    final children = await _getChildrenForBlock(id);
    return _mapToEntity(models.first, children);
  }

  @override
  Future<List<Block>> getBlocksByDocument(String documentId) async {
    // Get all blocks that belong to this document and have no parent
    final models = await _repository.get<BlockModel>();
    final filteredModels = models.where((model) => 
        model.projectId == documentId && model.parentId == null).toList();
    
    // Build hierarchy
    return await _buildBlockHierarchy(filteredModels);
  }

  @override
  Future<Map<String, List<Block>>> getBlocksByDocuments(
    List<String> documentIds,
  ) async {
    final result = <String, List<Block>>{};
    
    for (final documentId in documentIds) {
      result[documentId] = await getBlocksByDocument(documentId);
    }
    
    return result;
  }

  @override
  Future<void> createBlock(Block block) async {
    final model = _mapToModel(block);
    await _repository.upsert<BlockModel>(model);
    
    // Create children recursively
    for (final child in block.children) {
      final childModel = _mapToModel(child, parentId: block.id);
      await _repository.upsert<BlockModel>(childModel);
    }
  }

  @override
  Future<void> updateBlock(Block block) async {
    final model = _mapToModel(block);
    await _repository.upsert<BlockModel>(model);
    
    // Update children recursively
    for (final child in block.children) {
      final childModel = _mapToModel(child, parentId: block.id);
      await _repository.upsert<BlockModel>(childModel);
    }
  }

  @override
  Future<void> deleteBlock(String id) async {
    // Delete children first
    await _deleteChildrenRecursively(id);
    
    // Delete the block itself
    final models = await _repository.get<BlockModel>(
      query: Query.where('id', id),
    );
    if (models.isNotEmpty) {
      await _repository.delete<BlockModel>(models.first);
    }
  }

  @override
  Future<void> reorderBlocks(String documentId, List<String> blockIds) async {
    // This would be implemented based on how document ordering is handled
    // For now, this is a placeholder as the actual implementation depends on
    // how the Document model stores block order
    // TODO: Implement reordering logic
  }

  @override
  Stream<List<Block>> watchBlocksByDocument(String documentId) {
    // This would be implemented using Brick's streaming capabilities
    // For now, return a simple stream
    // TODO: Implement real-time streaming
    return Stream.fromFuture(getBlocksByDocument(documentId));
  }

  /// Gets children blocks for a given parent block ID
  Future<List<Block>> _getChildrenForBlock(String parentId) async {
    final childModels = await _repository.get<BlockModel>(
      query: Query.where('parentId', parentId),
    );
    
    final children = <Block>[];
    for (final childModel in childModels) {
      final grandChildren = await _getChildrenForBlock(childModel.id);
      children.add(_mapToEntity(childModel, grandChildren));
    }
    
    return children;
  }

  /// Builds block hierarchy from flat list of models
  Future<List<Block>> _buildBlockHierarchy(List<BlockModel> models) async {
    final blocks = <Block>[];
    
    for (final model in models) {
      final children = await _getChildrenForBlock(model.id);
      blocks.add(_mapToEntity(model, children));
    }
    
    return blocks;
  }

  /// Deletes all children of a block recursively
  Future<void> _deleteChildrenRecursively(String parentId) async {
    final childModels = await _repository.get<BlockModel>(
      query: Query.where('parentId', parentId),
    );
    
    for (final child in childModels) {
      await _deleteChildrenRecursively(child.id);
      await _repository.delete<BlockModel>(child);
    }
  }

  Block _mapToEntity(BlockModel model, List<Block> children) {
    return Block(
      id: model.id,
      type: model.type,
      content: model.content,
      metadata: model.metadata,
      children: children,
      projectId: model.projectId,
      date: model.date,
    );
  }

  BlockModel _mapToModel(Block entity, {String? parentId}) {
    return BlockModel(
      id: entity.id,
      type: entity.type,
      content: entity.content,
      metadata: entity.metadata,
      projectId: entity.projectId,
      date: entity.date,
      parentId: parentId,
    );
  }
}
