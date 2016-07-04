class DataSourcesController < ApplicationController
  permits :name, :description, :adapter, :host, :port, :dbname, :user, :password, :encoding

  before_action :require_admin_login, only: %w(new create edit update destroy)

  DUMMY_PASSWORD = "__DUMMY__"

  def index
    redirect_to setting_path
  end

  def show
    redirect_to setting_path
  end

  def new
    @data_source = DataSource.new
  end

  def create(data_source)
    @data_source = DataSource.create!(data_source_params(data_source))
    import_data_source_and_redirect!(@data_source)
  rescue ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
    redirect_to new_data_source_path
  end

  def edit(id)
    @data_source = DataSource.find(id)
    @data_source.password = DUMMY_PASSWORD
  end

  def update(id, data_source)
    @data_source = DataSource.find(id)
    @data_source.reset_data_source_tables!
    @data_source.assign_attributes(data_source_params(data_source))
    @data_source.save! if @data_source.changed?
    import_data_source_and_redirect!(@data_source)
  rescue  ActiveRecord::ActiveRecordError, DataSource::ConnectionBad => e
    flash[:error] = e.message
    redirect_to :back
  end

  def destroy(id)
    data_source = DataSource.find(id)
    data_source.destroy!
    redirect_to data_sources_path
  end

  private

  def data_source_params(data_source)
    data_source.reject!{|k, v| k == "password" && v == DUMMY_PASSWORD }
    data_source
  end

  def import_data_source_and_redirect!(data_source)
    DatabaseMemo.import_data_source!(data_source.id)
    flash[:info] = t("data_source_updated", name: data_source.name)
    redirect_to data_sources_path
  rescue ActiveRecord::ActiveRecordError, DataSource::ConnectionBad => e
    flash[:error] = e.message
    redirect_to data_sources_path
  end
end
