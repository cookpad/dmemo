class TopController < ApplicationController
  def show
    @database_memos = DatabaseMemo.all.includes(:data_source, schema_memos: :table_memos)
    @favorite_tables = current_user.favorite_tables.includes(:table_memo)
  end
end
