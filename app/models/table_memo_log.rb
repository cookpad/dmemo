class TableMemoLog < ActiveRecord::Base
  belongs_to :table_memo
  belongs_to :user
end
