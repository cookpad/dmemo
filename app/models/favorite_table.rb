class FavoriteTable < ApplicationRecord
  belongs_to :user
  belongs_to :table_memo
end
