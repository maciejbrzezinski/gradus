// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20250528183011.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20250528183011(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      'BlockModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('type', Column.varchar),
        SchemaColumn('content', Column.varchar),
        SchemaColumn('metadata', Column.varchar),
        SchemaColumn('project_id', Column.varchar),
        SchemaColumn('date', Column.datetime),
        SchemaColumn('parent_id', Column.varchar),
        SchemaColumn('id', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['parent_id'], unique: false),
        SchemaIndex(columns: ['id'], unique: true),
      },
    ),
    SchemaTable(
      'DocumentModel',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('title', Column.varchar),
        SchemaColumn('icon', Column.varchar),
        SchemaColumn('icon_color', Column.varchar),
        SchemaColumn('date', Column.datetime),
        SchemaColumn('block_ids', Column.varchar),
        SchemaColumn('id', Column.varchar, unique: true),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['id'], unique: true),
      },
    ),
  },
);
