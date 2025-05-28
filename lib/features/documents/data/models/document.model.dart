import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

/// Document model with Brick annotations for offline-first with Supabase
/// US-007: SQLite configuration with Brick
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'documents'),
)
class DocumentModel extends OfflineFirstWithSupabaseModel {
  /// Document title (for projects)
  final String? title;

  /// Document icon (for projects)
  final String? icon;

  /// Document icon color (for projects)
  final String? iconColor;

  /// Date for timeline documents (null for projects)
  final DateTime? date;

  /// Ordered list of block IDs
  @Supabase(name: 'block_ids')
  @Sqlite(name: 'block_ids')
  final List<String> blocks;

  /// Unique identifier - not auto incremented for offline-first strategy
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  DocumentModel({
    String? id,
    this.title,
    this.icon,
    this.iconColor,
    this.date,
    required this.blocks,
  }) : this.id = id ?? const Uuid().v4();
}
