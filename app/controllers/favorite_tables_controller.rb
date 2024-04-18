class FavoriteTablesController < ApplicationController
  def create(table_memo_id)
    @favorite_table = FavoriteTable.create!(user_id: current_user.id, table_memo_id:)
  end

  def destroy(table_memo_id)
    @favorite_table = FavoriteTable.find_by!(user_id: current_user.id, table_memo_id:)
    @favorite_table.destroy!
  end
end
