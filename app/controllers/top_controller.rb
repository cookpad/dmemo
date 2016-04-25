class TopController < ApplicationController
  def show
    @database_memos = DatabaseMemo.all.includes(:data_source, :table_memos)
  end
end
