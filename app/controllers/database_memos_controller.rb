class DatabaseMemosController < ApplicationController
  def index
    redirect_to root_path
  end

  def show
    @database_memo = DatabaseMemo.find_by!(name: params[:name])
  end

  def create
    if params[:data_source_id]
      DatabaseMemo.import_data_source!(params[:data_source_id])
    end
    redirect_to "/"
  end
end
