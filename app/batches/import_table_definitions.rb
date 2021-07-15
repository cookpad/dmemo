class ImportTableDefinitions

  def self.run(database_name, schema_name, table_name)
    data_source = DataSource.find_by(name: database_name)
    schema_memo = data_source.database_memo.schema_memos.find_by(name: schema_name)
    table_memo = schema_memo.table_memos.find_or_create_by(name: table_name)
    table_memo.linked = false

    source_table = data_source.data_source_tables.find {|dst| dst.full_table_name == "#{schema_name}.#{table_name}" }
    table_memo.linked = true unless source_table.nil?

    column_memos = table_memo.column_memos.to_a
    columns = source_table.columns

    column_names = columns.map(&:name)
    column_memos.reject {|memo| column_names.include?(memo.name) }.each {|memo| memo.update!(linked: false) }

    columns.each_with_index do |column, position|
      column_memo = column_memos.find {|memo| memo.name == column.name } || table_memo.column_memos.build(name: column.name)
      column_memo.linked = true
      column_memo.assign_attributes(sql_type: column.sql_type, default: column.default, nullable: column.null, position: position)
      column_memo.save! if column_memo.changed?
    end

    table_memo.save! if table_memo.changed?
  end
end
