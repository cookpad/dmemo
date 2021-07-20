class ImportDataSourceDefinitions

  def self.run(data_source_name)
    data_source = DataSource.find_by(name: data_source_name)
    data_source_tables = data_source.data_source_tables

    db_memo = DatabaseMemo.find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos
    schema_memos.each {|memo| memo.linked = false }

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten
    all_table_memos.each {|memo| memo.linked = false }

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      schema_memo = schema_memos.find_by!(name: schema_name)
      next if schema_mnemo.nil?
      schema_memo.update!(linked: true)
      begin
        ImportSchemaDefinitions.import_table_memos!(source_tables, schema_memo.table_memos)
      rescue DataSource::ConnectionBad => e
        Rails.logger.error e
      end
    end

    schema_memos.each {|memo| memo.save! if memo.has_changes_to_save? }
    db_memos.save! if db_memo.has_changes_to_save?
  end
end
