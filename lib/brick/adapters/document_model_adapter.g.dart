// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<DocumentModel> _$DocumentModelFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return DocumentModel(
    title: data['title'] == null ? null : data['title'] as String?,
    icon: data['icon'] == null ? null : data['icon'] as String?,
    iconColor:
        data['icon_color'] == null ? null : data['icon_color'] as String?,
    date:
        data['date'] == null
            ? null
            : data['date'] == null
            ? null
            : DateTime.tryParse(data['date'] as String),
    blocks: data['block_ids'].toList().cast<String>(),
    id: data['id'] as String?,
  );
}

Future<Map<String, dynamic>> _$DocumentModelToSupabase(
  DocumentModel instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'title': instance.title,
    'icon': instance.icon,
    'icon_color': instance.iconColor,
    'date': instance.date?.toIso8601String(),
    'block_ids': instance.blocks,
    'id': instance.id,
  };
}

Future<DocumentModel> _$DocumentModelFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return DocumentModel(
    title: data['title'] == null ? null : data['title'] as String?,
    icon: data['icon'] == null ? null : data['icon'] as String?,
    iconColor:
        data['icon_color'] == null ? null : data['icon_color'] as String?,
    date:
        data['date'] == null
            ? null
            : data['date'] == null
            ? null
            : DateTime.tryParse(data['date'] as String),
    blocks: jsonDecode(data['block_ids']).toList().cast<String>(),
    id: data['id'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DocumentModelToSqlite(
  DocumentModel instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'title': instance.title,
    'icon': instance.icon,
    'icon_color': instance.iconColor,
    'date': instance.date?.toIso8601String(),
    'block_ids': jsonEncode(instance.blocks),
    'id': instance.id,
  };
}

/// Construct a [DocumentModel]
class DocumentModelAdapter
    extends OfflineFirstWithSupabaseAdapter<DocumentModel> {
  DocumentModelAdapter();

  @override
  final supabaseTableName = 'documents';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'title': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'title',
    ),
    'icon': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'icon',
    ),
    'iconColor': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'icon_color',
    ),
    'date': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'date',
    ),
    'blocks': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'block_ids',
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
    'title': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'title',
      iterable: false,
      type: String,
    ),
    'icon': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'icon',
      iterable: false,
      type: String,
    ),
    'iconColor': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'icon_color',
      iterable: false,
      type: String,
    ),
    'date': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'date',
      iterable: false,
      type: DateTime,
    ),
    'blocks': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'block_ids',
      iterable: true,
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
    DocumentModel instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `DocumentModel` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'DocumentModel';

  @override
  Future<DocumentModel> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DocumentModelFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    DocumentModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DocumentModelToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<DocumentModel> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DocumentModelFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    DocumentModel input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DocumentModelToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
