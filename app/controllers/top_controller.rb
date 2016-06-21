class TopController < ApplicationController
  def show
    @database_memos = DatabaseMemo.all.includes(:data_source, :table_memos)
    @favorite_tables = current_user.favorite_tables.includes(:table_memo)
  end
end
