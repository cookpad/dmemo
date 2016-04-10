class DatabaseMemosController < ApplicationController
  def create
    if params[:data_source_id]
      DatabaseMemo.import_data_source!(params[:data_source_id])
    end
    redirect_to "/"
  end
end
