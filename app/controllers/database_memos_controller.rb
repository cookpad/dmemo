class DatabaseMemosController < ApplicationController
  def index
    redirect_to root_path
  end

  def show
    if params[:database_name]
      @database_memo = DatabaseMemo.includes(table_memos: :column_memos).find_by!(name: params[:database_name])
    else
      @database_memo = DatabaseMemo.includes(table_memos: :column_memos).find(params[:id])
    end
  end

  def create
    if params[:data_source_id]
      DatabaseMemo.import_data_source!(params[:data_source_id])
    end
    redirect_to "/"
  end

  def update
    @database_memo = DatabaseMemo.find(params[:id])
    case params[:name]
      when "name"
        @database_memo.update!(name: params[:value])
      when "description"
        @database_memo.update!(description: params[:value])
    end
  end

  def destroy
    database_memo = DatabaseMemo.find(params[:id])
    database_memo.destroy!
    redirect_to root_path
  end
end
