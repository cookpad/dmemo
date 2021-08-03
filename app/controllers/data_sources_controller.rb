class DataSourcesController < ApplicationController
  before_action :require_admin_login, only: %w(new create edit update destroy import_schema remove_schema)

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

    begin
      @data_source_schemas = @data_source.data_source_adapter.fetch_schema_names # [[schema_name, schema_owner], ...]
      @data_source_schema_names = @data_source_schemas.map(&:first)

      @imported_schema_memos = @data_source.database_memo.schema_memos
      @subscribe_schema_names = @imported_schema_memos.where(linked: true).map(&:name)
      @only_dmemo_schema_names = @imported_schema_memos.pluck(:name) - @data_source_schema_names
      @only_dmemo_schemas = @only_dmemo_schema_names.map{|s| [s, 'unknown']}
      @all_schemas = (@data_source_schemas + @only_dmemo_schemas).sort_by{|s| s[0]} # s[0] is schema name
    rescue NotImplementedError => e
      # when not implement fetch_schema_names for adapter
      # data_sources/:id/edit page does not view Schema Candidates block
    rescue ActiveRecord::ActiveRecordError, DataSource::ConnectionBad => e
      flash[:error] = e.message
      redirect_to data_sources_path
    end

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

  def import_schema(id, schema_name)
    data_source = DataSource.includes(:database_memo).find(id)
    schema_memo = data_source.database_memo.schema_memos.find_or_create_by(name: schema_name)
    schema_memo.update!(linked: true)

    # import_schema
    redirect_to edit_data_source_path(id)
  end

  def unlink_schema(id, schema_name)
    data_source = DataSource.includes(database_memo: :schema_memos).find(id)
    schema_memo = data_source.database_memo.schema_memos.find_by(name: schema_name)
    schema_memo.update!(linked: false)

    redirect_to edit_data_source_path(id)
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
