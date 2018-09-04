class DatabaseMemoLog < ApplicationRecord
  belongs_to :database_memo
  belongs_to :user
end
