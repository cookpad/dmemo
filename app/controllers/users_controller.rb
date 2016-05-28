class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show(id)
    @user = User.find(id)
  end

  def edit(id)
    @user = User.find(id)
  end

  def update(id, user)
    @user = User.find(id)
    @user.update!(user)
    redirect_to @user
  end
end
