class TableMemo < ActiveRecord::Base
  belongs_to :database_memo

  has_many :column_memos

  def source_table_class
    database_memo.data_source.try(:source_table_class, name)
  end

  def source_column_class(column_name)
    source_table_class.try {|table_class| table_class.columns.find {|column_class| column_class.name == column_name } }
  end

  def linked?
    source_table_class
  end
end
