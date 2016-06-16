class ColumnMemoLog < ActiveRecord::Base
  belongs_to :column_memo
  belongs_to :user
end
