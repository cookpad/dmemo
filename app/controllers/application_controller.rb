class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_database_memo_names

  private

  def set_database_memo_names
    @database_memo_names = DatabaseMemo.all.pluck(:id, :name)
  end
end
