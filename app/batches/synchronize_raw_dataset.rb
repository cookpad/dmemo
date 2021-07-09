class SynchronizeRawDataset
  DEFAULT_FETCH_ROWS_LIMIT = 20

  def self.run
    DataSource.all.find_each do |data_source|
      import_data_source!(data_source)
    end
  end

  def self.import_data_source!(data_source)
    db_memo = DatabaseMemo.find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos.includes(table_memos: [:column_memos, :raw_dataset]).to_a

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten

    data_source_tables = data_source.data_source_tables

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      schema_memo = schema_memos.find {|memo| memo.name == schema_name } || db_memo.schema_memos.create!(name: schema_name )
      table_memos = all_table_memos.select {|memo| memo.schema_memo_id == schema_memo.id }

      source_tables.each do |source_table|
        begin
          import_table_memo!(schema_memo, table_memos, source_table)
        rescue DataSource::ConnectionBad => e
          Rails.logger.error e
        end
      end
    end
  end

  def self.import_table_memo!(schema_memo, table_memos, source_table)
    table_name = source_table.table_name
    table_memo = table_memos.find {|memo| memo.name == table_name } || schema_memo.table_memos.create!(name: table_name )

    columns = source_table.columns
    import_table_memo_raw_dataset!(table_memo, source_table, columns)
    import_view_query!(table_memo, source_table)

  end
  private_class_method :import_table_memo!

  def self.import_table_memo_raw_dataset!(table_memo, source_table, columns)
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
  private_class_method :import_table_memo_raw_dataset!

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
  private_class_method :import_table_memo_raw_dataset_rows!

  def self.import_view_query!(table_memo, source_table)
    return unless source_table.data_source.adapter.is_a?(DataSourceAdapters::RedshiftAdapter)

    query = source_table.fetch_view_query
    if query
      query_plan = source_table.fetch_view_query_plan

      ViewMetaDatum.find_or_initialize_by(table_memo_id: table_memo.id) do |meta_data|
        meta_data.query = query
        meta_data.explain = query_plan || 'explain error'
        meta_data.save
      end
    end
  end
  private_class_method :import_view_query!
end
