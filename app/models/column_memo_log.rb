class ColumnMemoLog < ApplicationRecord
  belongs_to :column_memo
  belongs_to :user
end
