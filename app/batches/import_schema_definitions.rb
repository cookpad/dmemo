class ImportSchemaDefinitions

  def self.run(data_source_name, schema_name)
    data_source = DataSource.find_by(name: data_source_name)
    source_tables = data_source.data_source_tables.select {|table| table.schema_name == schema_name }

    schema_memo = data_source.database_memo.schema_memos.find_or_create_by(name: schema_name)
    table_memos = schema_memo.table_memos
    table_memos.each {|memo| memo.linked = false }

    if source_tables.empty?
      schema_memo.linked = false
    else
      schema_memo.linked = true
      self.import_table_memos!(source_tables, table_memos)
    end

    table_memos.each {|memo| memo.save! if memo.has_changes_to_save? }
    schema_memo.save! if schema_memo.has_changes_to_save?
  end

  def self.import_table_memos!(source_tables, table_memos)
    source_tables.each do |source_table|
      table_memo = table_memos.find_or_create_by(name: source_table.table_name)
      table_memo.update!(linked: true)
      begin
        ImportTableDefinitions.import_column_memos!(source_table, table_memo)
      rescue DataSource::ConnectionBad => e
        Rails.logger.error e
      end
    end
  end
end
