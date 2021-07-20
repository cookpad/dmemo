class ImportTableRawDatasets
  DEFAULT_FETCH_ROWS_LIMIT = 20

  def self.run(data_source_name, schema_name, table_name)
    data_source = DataSource.find_by(name: data_source_name)
    source_table = data_source.data_source_tables.find {|dst| dst.full_table_name == "#{schema_name}.#{table_name}" }

    schema_memo = data_source.database_memo.schema_memos.find_by(name: schema_name)
    table_memo = schema_memo.table_memos.find_or_create_by!(name: table_name)

    begin
      import_table_memo_raw_dataset!(table_memo, source_table)
    rescue DataSource::ConnectionBad => e
      Rails.logger.error e
    end
  end

  def self.import_table_memo_raw_dataset!(table_memo, source_table)
    columns = source_table.columns
    table_count = source_table.fetch_count
    if table_memo.raw_dataset
      unless table_memo.raw_dataset.same_columns?(columns) && (table_memo.raw_dataset.rows.count >= DEFAULT_FETCH_ROWS_LIMIT || table_memo.raw_dataset.rows.count == table_count)
        import_table_memo_raw_dataset_rows!(table_memo, source_table, columns)
      end
      table_memo.raw_dataset.update!(count: table_count)
    else
      table_memo.create_raw_dataset!(count: table_count)
      import_table_memo_raw_dataset_rows!(table_memo, source_table, columns)
    end
  end

  def self.import_table_memo_raw_dataset_rows!(table_memo, source_table, columns)
    table_memo.raw_dataset.columns.delete_all
    dataset_columns = columns.map.with_index do |column, position|
      table_memo.raw_dataset.columns.create!(name: column.name, sql_type: column.sql_type, position: position)
    end
    table_memo.raw_dataset.rows.delete_all
    source_table.fetch_rows(DEFAULT_FETCH_ROWS_LIMIT).each do |row|
      table_memo.raw_dataset.rows.create!(row: row.map.with_index{|value, i| dataset_columns[i].format_value(value) })
    end
  end
end
