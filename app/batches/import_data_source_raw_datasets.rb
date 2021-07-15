class ImportDataSourceRawDatasets

  def self.run(data_source_name)
    data_source = DataSource.find_by(name: data_source_name)
    data_source_tables = data_source.data_source_tables

    db_memo = DatabaseMemo.find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos.includes(table_memos: [:column_memos, :raw_dataset])

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten

    data_source_tables = data_source.data_source_tables

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      schema_memo = db_memo.schema_memos.find_or_create_by(name: schema_name)
      table_memos = schema_memo.table_memos

      source_tables.each do |source_table|
        table_memo = schema_memo.table_memos.find_or_create_by(name: source_table.table_name)
        begin
          ImportTableRawDatasets.import_table_memo_raw_dataset!(table_memo, source_table)
        rescue DataSource::ConnectionBad => e
          Rails.logger.error e
        end
      end
    end
  end
end
