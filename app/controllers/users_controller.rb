class UsersController < ApplicationController
  permits :name

  before_action :require_editable, only: %w(edit update)

  def index
    @users = User.all
  end

  def edit(id)
    @user = User.find(id)
  end

  def update(id, user)
    @user = User.find(id)
    @user.update!(user)
    redirect_to edit_user_path(@user)
  end

  private

  def require_editable(id)
    head 401 unless current_user.editable_user?(id)
  end
end
