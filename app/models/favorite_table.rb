class FavoriteTable < ActiveRecord::Base
  belongs_to :user
  belongs_to :table_memo
end
