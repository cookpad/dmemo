class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  before_action :require_login
  before_action :set_sidebar_databases

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user
    redirect_to "/auth/google_oauth2"
  end

  def require_admin_login
    redirect_to root_path unless current_user.admin?
  end

  def set_sidebar_databases
    @sidebar_databases = DatabaseMemo.all.select(:name)
  end
end
