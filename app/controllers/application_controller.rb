class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :require_login
  before_action :set_database_memo_names

  private

  def current_user
    @current_user ||= User.from_session(session[:user]) if session[:user]
  end

  def require_login
    return if current_user
    redirect_to "/auth/google_oauth2"
  end

  def set_database_memo_names
    @database_memo_names = DatabaseMemo.all.pluck(:name)
  end
end
