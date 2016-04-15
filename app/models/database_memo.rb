class DatabaseMemo < ActiveRecord::Base

  has_many :table_memos

  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)

    db_memo = find_or_create_by!(name: data_source.name)

    data_source.source_table_classes.each do |table_class|
      table_memo = db_memo.table_memos.find_or_create_by!(name: table_class.table_name)
      table_class.columns.each do |column|
        adapter = table_class.connection.pool.connections.first
        column_memo = table_memo.column_memos.find_or_initialize_by(name: column.name)
        column_memo.update!(sql_type: column.sql_type, default: adapter.quote(column.default), nullable: column.null)
      end
    end
  end
end
