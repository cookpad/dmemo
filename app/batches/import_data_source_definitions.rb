class ImportDataSourceDefinitions

  def self.run(data_source_name)
    Rails.logger.info "[Start] Import dataset in #{data_source_name}"

    data_source = DataSource.find_by(name: data_source_name)
    data_source_tables = data_source.data_source_tables

    db_memo = DatabaseMemo.find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos
    linked_schema_names = schema_memos.where(linked: true).pluck(:name)
    schema_memos.each {|memo| memo.linked = false }

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten
    all_table_memos.each {|memo| memo.linked = false }

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      next unless linked_schema_names.include?(schema_name)
      schema_memo = schema_memos.find {|memo| memo.name == schema_name }
      next if schema_memo.nil?
      schema_memo.linked = true
      begin
        ImportSchemaDefinitions.import_table_memos!(source_tables, schema_memo.table_memos)
      rescue DataSource::ConnectionBad => e
        Rails.logger.error e
      end
    end

    schema_memos.each {|memo| memo.save! if memo.has_changes_to_save? }
    db_memos.save! if db_memo.has_changes_to_save?
  end

  Rails.logger.info "[Finish] Imported dataset"
end
