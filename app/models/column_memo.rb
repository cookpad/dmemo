class ColumnMemo < ActiveRecord::Base
  belongs_to :table_memo

  def source_column_class
    table_memo.source_column_class(name)
  end

  def linked?
    source_column_class.present?
  end
end
