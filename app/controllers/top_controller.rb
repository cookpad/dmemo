class TopController < ApplicationController
  def show
    @database_memos = DatabaseMemo.all.includes(:data_source, schema_memos: :table_memos).sort_by(&:display_order)
    if current_user
      @favorite_tables = TableMemo.where(id: current_user.favorite_tables.pluck(:table_memo_id))
    end
  end
end
