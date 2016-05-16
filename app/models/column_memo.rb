class ColumnMemo < ActiveRecord::Base
  belongs_to :table_memo

  def source_column_class
    table_memo.source_column_class(name)
  end

  def linked?
    table_memo.linked? && source_column_class.present?
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error
    false
  end
end
