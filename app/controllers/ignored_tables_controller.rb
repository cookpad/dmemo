class IgnoredTablesController < ApplicationController
  permits :data_source_id, :pattern

  before_action :require_admin_login, only: %w(new create destroy)

  def index
    redirect_to setting_path
  end

  def show
    redirect_to setting_path
  end

  def new
    @ignored_table = IgnoredTable.new
    @database_name_options = DataSource.pluck(:name, :id)
  end

  def create(ignored_table)
    @ignored_table = IgnoredTable.create!(ignored_table)
    redirect_to setting_path
  rescue  ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
    redirect_to new_ignored_table_path(@ignored_table)
  end

  def destroy(id)
    @ignored_table = IgnoredTable.find(id)
    @ignored_table.destroy!
    redirect_to setting_path
  end
end
