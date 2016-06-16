class DatabaseMemoLog < ActiveRecord::Base
  belongs_to :database_memo
  belongs_to :user
end
