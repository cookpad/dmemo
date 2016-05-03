class SessionsController < ApplicationController
  skip_before_action :require_login, :create

  def create
    auth = env["omniauth.auth"]
    session[:user] = {
      uid: auth[:uid],
      info: auth[:info],
      provider: auth[:provider],
    }
    redirect_to root_path
  end

  def destroy
    session[:user] = nil
    redirect_to root_path
  end
end
