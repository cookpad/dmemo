class DataSourcesController < ApplicationController
  permits :name, :description, :adapter, :host, :port, :dbname, :user, :password, :encoding

  DUMMY_PASSWORD = "__DUMMY__"

  def index
    @data_sources = DataSource.all
  end

  def new
    @data_source = DataSource.new
  end

  def create(data_source)
    DataSource.create!(data_source_params(data_source))
    redirect_to data_sources_path
  end

  def edit(id)
    @data_source = DataSource.find(id)
    @data_source.password = DUMMY_PASSWORD
  end

  def update(id, data_source)
    @data_source = DataSource.find(id)
    @data_source.assign_attributes(data_source_params(data_source))
    @data_source.save! if @data_source.changed?
    DatabaseMemo.import_data_source!(@data_source.id)
    flash[:updated] = t("data_source_updated", name: @data_source.name)
    redirect_to data_sources_path
  rescue ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
    redirect_to data_sources_path
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
end
