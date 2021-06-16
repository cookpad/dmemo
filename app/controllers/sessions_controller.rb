class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :callback]

  def new
    redirect_to root_path if session[:user_id]
    session[:return_to] = params[:return_to]
  end
  def callback
    auth = request.env["omniauth.auth"]
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

    if ReturnToValidator.valid?(session[:return_to])
      redirect_to session[:return_to]
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
