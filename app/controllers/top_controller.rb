class TopController < ApplicationController
  def show
    @database_memos = DatabaseMemo.all.includes(:data_source, schema_memos: :table_memos).sort_by(&:display_order)
    @favorite_tables = current_user.favorite_tables.includes(:table_memo)
  end
end
