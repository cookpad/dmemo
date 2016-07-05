# Add schema_memos
#
# - Create table schema_memos
# - Drop column table_memos.database_memo_id
# - Add column table_memos.schema_memo_id
# - Cleanup existing table_memos records

con = DatabaseMemo.connection
exit if con.table_exists?("schema_memos")

con.transaction do
  con.create_table "schema_memos", force: :cascade do |t|
    t.integer  "database_memo_id",              null: false
    t.string   "name",                          null: false
    t.text     "description",      default: "", null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  con.add_index "schema_memos", ["database_memo_id", "name"], name: "uniq_schema_name", unique: true, using: :btree
  con.remove_index "table_memos", name: "uniq_table_name"
  con.add_column "table_memos", "schema_memo_id", :integer, after: :id

  DatabaseMemo.find_each do |database_memo|
    connection = database_memo.data_source.source_base_class.connection
    table_names = case connection
      when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, ActiveRecord::ConnectionAdapters::RedshiftAdapter
        connection.query(<<-SQL, 'SCHEMA')
          SELECT schemaname, tablename
          FROM (
            SELECT schemaname, tablename FROM pg_tables WHERE schemaname = ANY (current_schemas(false))
            UNION
            SELECT schemaname, viewname AS tablename FROM pg_views WHERE schemaname = ANY (current_schemas(false))
          ) tables
          ORDER BY schemaname, tablename;
        SQL
      else
        connection.tables.map {|table_name| ["_", table_name] }
    end
    TableMemo.where(database_memo_id: database_memo.id).find_each do |table_memo|
      schema_name, _ = table_names.find {|_, table| table == table_memo.name }

      # delete unlinked table memo
      unless connection.table_exists?(table_memo.name)
        table_memo.destroy!
        next
      end

      schema_memo = database_memo.schema_memos.find_by(name: schema_name) || database_memo.schema_memos.create!(name: schema_name)
      table_memo.update!(schema_memo_id: schema_memo.id)
    end
  end

  con.change_column "table_memos", "schema_memo_id", :integer, null: false
  con.remove_column "table_memos", "database_memo_id"
  con.add_index "table_memos", ["schema_memo_id", "name"], name: "uniq_table_name", unique: true, using: :btree
end
