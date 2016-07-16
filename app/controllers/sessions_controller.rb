class SessionsController < ApplicationController
  skip_before_action :require_login, :create

  def create
    auth = env["omniauth.auth"]
    user = User.find_or_initialize_by(
      provider: auth[:provider],
      uid: auth[:uid],
    )
    user.assign_attributes(
      name: auth[:info][:name],
      email: auth[:info][:email],
      image_url: auth[:info][:image],
    )
    user.save! if user.changed?

    session[:user_id] = user.id
    return_to = root_path
    if ReturnToValidator.valid?(params[:state])
      return_to = params[:state]
    end
    redirect_to return_to
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
