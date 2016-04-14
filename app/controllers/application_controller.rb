class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_data_sources
  before_action :set_database_memos

  private

  def set_data_sources
    @data_sources = DataSource.all
  end

  def set_database_memos
    @database_memos = DatabaseMemo.all
  end
end
