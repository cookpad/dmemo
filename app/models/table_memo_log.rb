class TableMemoLog < ApplicationRecord
  belongs_to :table_memo
  belongs_to :user
end
