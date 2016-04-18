class DataSourcesController < ApplicationController
  def index
    @data_sources = DataSource.all
  end

  def new
    @data_source = DataSource.new
  end

  def create
    DataSource.create!(data_source_params)
    redirect_to data_sources_path
  end

  def edit
    @data_source = DataSource.find(params[:id])
  end

  def update
    data_source = DataSource.find(params[:id])
    data_source.update!(data_source_params)
    redirect_to data_sources_path
  end

  def destroy
    data_source = DataSource.find(params[:id])
    data_source.destroy!
    redirect_to data_sources_path
  end

  private

  def data_source_params
    params.
      require(:data_source).
      permit(:name, :description, :adapter, :host, :port, :dbname, :user, :password, :encoding).
      reject {|k, v| v.blank? }
  end
end
