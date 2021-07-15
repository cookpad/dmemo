class ImportSchemaDefinitions

  def self.run(database_name, schema_name)
    data_source = DataSource.find_by(name: database_name)
    schema_memo = data_source.database_memo.schema_memos.find_or_create_by(name: schema_name)
    schema_memo.linked = false

    table_memos = schema_memo.table_memos
    table_memos.each {|memo| memo.linked = false }

    source_tables = data_source.data_source_tables.select {|table| table.schema_name == schema_name }
    schema_memo.linked = true unless source_tables.empty?

    source_tables.each do |source_table|
      begin
        table_memo = table_memos.find_or_create_by(name: source_table.table_name)
        table_memo.linked = true

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
      rescue DataSource::ConnectionBad => e
        Rails.logger.error e
      end
    end

    table_memos.each {|memo| memo.save! if memo.changed? }
    schema_memo.save! if schema_memo.changed?
  end

end
