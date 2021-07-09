class SynchronizeDefinitions

  def self.run
    DataSource.all.find_each do |data_source|
      import_data_source!(data_source)
    end
  end

  def self.import_data_source!(data_source)
    db_memo = DatabaseMemo.find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos.includes(table_memos: [:column_memos, :raw_dataset]).to_a
    schema_memos.each {|memo| memo.linked = false }

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten
    all_table_memos.each {|memo| memo.linked = false }

    data_source_tables = data_source.data_source_tables

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      schema_memo = schema_memos.find {|memo| memo.name == schema_name } || db_memo.schema_memos.create!(name: schema_name )
      schema_memo.linked = true
      table_memos = all_table_memos.select {|memo| memo.schema_memo_id == schema_memo.id }

      source_tables.each do |source_table|
        begin
          import_table_memo!(schema_memo, table_memos, source_table)
        rescue DataSource::ConnectionBad => e
          Rails.logger.error e
        end
      end
    end
    schema_memos.each {|memo| memo.save! if memo.changed? }
    all_table_memos.each {|memo| memo.save! if memo.changed? }
  end

  def self.import_table_memo!(schema_memo, table_memos, source_table)
    table_name = source_table.table_name
    table_memo = table_memos.find {|memo| memo.name == table_name } || schema_memo.table_memos.create!(name: table_name )
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

    table_memo.save! if table_memo.changed?
  end
  private_class_method :import_table_memo!
end
