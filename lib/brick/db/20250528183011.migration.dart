// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250528183011_up = [
  InsertTable('BlockModel'),
  InsertTable('DocumentModel'),
  InsertColumn('type', Column.varchar, onTable: 'BlockModel'),
  InsertColumn('content', Column.varchar, onTable: 'BlockModel'),
  InsertColumn('metadata', Column.varchar, onTable: 'BlockModel'),
  InsertColumn('project_id', Column.varchar, onTable: 'BlockModel'),
  InsertColumn('date', Column.datetime, onTable: 'BlockModel'),
  InsertColumn('parent_id', Column.varchar, onTable: 'BlockModel'),
  InsertColumn('id', Column.varchar, onTable: 'BlockModel', unique: true),
  InsertColumn('title', Column.varchar, onTable: 'DocumentModel'),
  InsertColumn('icon', Column.varchar, onTable: 'DocumentModel'),
  InsertColumn('icon_color', Column.varchar, onTable: 'DocumentModel'),
  InsertColumn('date', Column.datetime, onTable: 'DocumentModel'),
  InsertColumn('block_ids', Column.varchar, onTable: 'DocumentModel'),
  InsertColumn('id', Column.varchar, onTable: 'DocumentModel', unique: true),
  CreateIndex(columns: ['parent_id'], onTable: 'BlockModel', unique: false),
  CreateIndex(columns: ['id'], onTable: 'BlockModel', unique: true),
  CreateIndex(columns: ['id'], onTable: 'DocumentModel', unique: true)
];

const List<MigrationCommand> _migration_20250528183011_down = [
  DropTable('BlockModel'),
  DropTable('DocumentModel'),
  DropColumn('type', onTable: 'BlockModel'),
  DropColumn('content', onTable: 'BlockModel'),
  DropColumn('metadata', onTable: 'BlockModel'),
  DropColumn('project_id', onTable: 'BlockModel'),
  DropColumn('date', onTable: 'BlockModel'),
  DropColumn('parent_id', onTable: 'BlockModel'),
  DropColumn('id', onTable: 'BlockModel'),
  DropColumn('title', onTable: 'DocumentModel'),
  DropColumn('icon', onTable: 'DocumentModel'),
  DropColumn('icon_color', onTable: 'DocumentModel'),
  DropColumn('date', onTable: 'DocumentModel'),
  DropColumn('block_ids', onTable: 'DocumentModel'),
  DropColumn('id', onTable: 'DocumentModel'),
  DropIndex('index_BlockModel_on_parent_id'),
  DropIndex('index_BlockModel_on_id'),
  DropIndex('index_DocumentModel_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250528183011',
  up: _migration_20250528183011_up,
  down: _migration_20250528183011_down,
)
class Migration20250528183011 extends Migration {
  const Migration20250528183011()
    : super(
        version: 20250528183011,
        up: _migration_20250528183011_up,
        down: _migration_20250528183011_down,
      );
}
