class ImportSchemaRawDatasets

  def self.run(data_source_name, schema_name)
    Rails.logger.info "[Start] Import dataset of #{schema_name} schema in #{data_source_name}"

    data_source = DataSource.find_by(name: data_source_name)
    source_tables = data_source.data_source_tables.select { |dst| dst.schema_name == schema_name }

    schema_memo = data_source.database_memo.schema_memos.find_by!(name: schema_name, linked: true)

    source_tables.each do |source_table|
      table_memo = schema_memo.table_memos.find_or_create_by!(name: source_table.table_name)
      begin
        ImportTableRawDatasets.import_table_memo_raw_dataset!(table_memo, source_table)
      rescue DataSource::ConnectionBad => e
        Rails.logger.error e
      end
    end
  end

  Rails.logger.info "[Finish] Imported dataset"
end
