import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

/// Block model with Brick annotations for offline-first with Supabase
/// US-007: SQLite configuration with Brick
@ConnectOfflineFirstWithSupabase(supabaseConfig: SupabaseSerializable(tableName: 'blocks'))
class BlockModel extends OfflineFirstWithSupabaseModel {
  /// Block type (text, todo, heading, etc.)
  final String type;

  /// Block content (dynamic to support different block types)
  final Map<String, dynamic> content;

  /// Block metadata
  final Map<String, dynamic> metadata;

  /// Project ID if block belongs to a project
  @Supabase(name: 'project_id')
  @Sqlite(name: 'project_id')
  final String? projectId;

  /// Date if block belongs to a specific day in timeline
  final DateTime? date;

  /// Parent block ID for nested blocks
  @Supabase(name: 'parent_id')
  @Sqlite(name: 'parent_id', index: true)
  final String? parentId;

  /// Unique identifier - not auto incremented for offline-first strategy
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  BlockModel({
    String? id,
    required this.type,
    required this.content,
    required this.metadata,
    this.projectId,
    this.date,
    this.parentId,
  }) : this.id = id ?? const Uuid().v4();
}
