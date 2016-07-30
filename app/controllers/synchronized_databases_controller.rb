class SynchronizedDatabasesController < ApplicationController
  before_action :require_admin_login

  def update(data_source_id)
    @data_source = DataSource.find(data_source_id)
    @data_source.reset_data_source_tables!
    DatabaseMemo.import_data_source!(data_source_id)
    flash[:info] = t("data_source_synchronized", name: @data_source.name)
    redirect_to setting_path, status: 301
  rescue  ActiveRecord::ActiveRecordError, DataSource::ConnectionBad => e
    flash[:error] = e.message
    redirect_to setting_path, status: 301
  end
end
