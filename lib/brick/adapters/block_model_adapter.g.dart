// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<BlockModel> _$BlockModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return BlockModel(
    type: data['type'] as String,
    content: data['content'],
    metadata: data['metadata'],
    projectId:
        data['project_id'] == null ? null : data['project_id'] as String?,
    date:
        data['date'] == null
            ? null
            : data['date'] == null
            ? null
            : DateTime.tryParse(data['date'] as String),
    parentId: data['parent_id'] == null ? null : data['parent_id'] as String?,
    id: data['id'] as String?,
  );
}

Future<Map<String, dynamic>> _$BlockModelToSupabase(
  BlockModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'type': instance.type,
    'content': instance.content,
    'metadata': instance.metadata,
    'project_id': instance.projectId,
    'date': instance.date?.toIso8601String(),
    'parent_id': instance.parentId,
    'id': instance.id,
  };
}

Future<BlockModel> _$BlockModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return BlockModel(
    type: data['type'] as String,
    content: jsonDecode(data['content']),
    metadata: jsonDecode(data['metadata']),
    projectId:
        data['project_id'] == null ? null : data['project_id'] as String?,
    date:
        data['date'] == null
            ? null
            : data['date'] == null
            ? null
            : DateTime.tryParse(data['date'] as String),
    parentId: data['parent_id'] == null ? null : data['parent_id'] as String?,
    id: data['id'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$BlockModelToSqlite(
  BlockModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'type': instance.type,
    'content': jsonEncode(instance.content),
    'metadata': jsonEncode(instance.metadata),
    'project_id': instance.projectId,
    'date': instance.date?.toIso8601String(),
    'parent_id': instance.parentId,
    'id': instance.id,
  };
}

/// Construct a [BlockModel]
class BlockModelAdapter extends OfflineFirstWithSupabaseAdapter<BlockModel> {
  BlockModelAdapter();

  @override
  final supabaseTableName = 'blocks';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'type': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'type',
    ),
    'content': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'content',
    ),
    'metadata': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'metadata',
    ),
    'projectId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'project_id',
    ),
    'date': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'date',
    ),
    'parentId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'parent_id',
    ),
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'id'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'type': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'type',
      iterable: false,
      type: String,
    ),
    'content': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'content',
      iterable: false,
      type: Map,
    ),
    'metadata': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'metadata',
      iterable: false,
      type: Map,
    ),
    'projectId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'project_id',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: DateTime,
    ),
    'parentId': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'parent_id',
      iterable: false,
      type: String,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    BlockModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `BlockModel` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'BlockModel';

  @override
  Future<BlockModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$BlockModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    BlockModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$BlockModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<BlockModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$BlockModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    BlockModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$BlockModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
