class DataSourcesController < ApplicationController
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

  def create
    ActiveRecord::Base.transaction do
      @data_source = DataSource.create!(data_source_params)
      create_or_update_bigquery_config(@data_source)
    end
    flash[:info] = t("data_source_updated", name: @data_source.name)
    redirect_to data_sources_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
    redirect_to new_data_source_path
  end

  def edit(id)
    @data_source = DataSource.find(id)
    @data_source.password = DUMMY_PASSWORD
  end

  def update(id)
    @data_source = DataSource.find(id)
    ActiveRecord::Base.transaction do
      @data_source.update!(data_source_params)
      create_or_update_bigquery_config(@data_source)
    end
    flash[:info] = t("data_source_updated", name: @data_source.name)
    redirect_to data_sources_path
  rescue ActiveRecord::ActiveRecordError, DataSource::ConnectionBad => e
    flash[:error] = e.message
    redirect_to edit_data_source_path(id)
  end

  def destroy(id)
    data_source = DataSource.find(id)
    data_source.destroy!
    redirect_to data_sources_path
  end

  private

  def data_source_params
    params.require(:data_source).permit(
      :name,
      :description,
      :adapter,
      :host,
      :port,
      :dbname,
      :user,
      :password,
      :encoding)
      .reject { |k, v| k == "password" && v == DUMMY_PASSWORD }
  end

  def create_or_update_bigquery_config(data_source)
    return unless params[:data_source][:adapter] == 'bigquery'

    bigquery_config_params = params[:data_source].require(:bigquery_config).permit(:project_id, :dataset, :credentials)

    if bigquery_config_params[:credentials]
      bigquery_config_params[:credentials] = bigquery_config_params[:credentials].read
    end

    BigqueryConfig.find_or_initialize_by(data_source: data_source).update!(bigquery_config_params)
  end
end
