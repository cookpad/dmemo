class TopController < ApplicationController
  def show
    @data_sources = DataSource.all
    @database_memos = DatabaseMemo.all
  end
end
