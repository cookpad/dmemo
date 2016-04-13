class DatabaseMemo < ActiveRecord::Base

  has_many :table_memos

  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)

    transaction do
      db_memo = find_or_create_by!(name: data_source.dbname)

      data_source.source_table_classes.each do |table|
        table_memo = db_memo.table_memos.find_or_create_by!(name: table.table_name)
        table.columns.each do |column|
          column_memo = table_memo.column_memos.find_or_create_by!(name: column.name)
        end
      end
    end
  end
end
