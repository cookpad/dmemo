class TableMemo < ActiveRecord::Base
  belongs_to :database_memo

  has_many :column_memos
end
