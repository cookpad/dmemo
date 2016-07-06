class UsersController < ApplicationController
  permits :name, :admin

  before_action :require_editable, only: %w(edit update)

  def index
    @users = User.all
  end

  def edit(id)
    @user = User.find(id)
  end

  def update(id, user)
    return head 401 if user.has_key?("admin") && !current_user.admin?
    @user = User.find(id)
    @user.update!(user)
    flash[:info] = "User #{@user.name} updated"
    redirect_to edit_user_path(@user)
  end

  private

  def require_editable(id)
    head 401 unless current_user.editable_user?(id)
  end
end
