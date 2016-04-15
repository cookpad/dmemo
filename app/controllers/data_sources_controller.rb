class DataSourcesController < ApplicationController
  def index
    @data_sources = DataSource.all
  end

  def new
    @data_source = DataSource.new
  end

  def create
    data_source = DataSource.create!(data_source_params)
    redirect_to edit_data_source_path(data_source)
  end

  def edit
    @data_source = DataSource.find(params[:id])
  end

  def update
    data_source = DataSource.find(params[:id])
    data_source.update!(data_source_params)
    redirect_to edit_data_source_path(data_source)
  end

  def destroy
  end

  private

  def data_source_params
    params.require(:data_source).permit(:name, :description, :adapter, :host, :port, :dbname, :user, :password, :encoding)
  end
end
