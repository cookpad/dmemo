class DatabaseMemosController < ApplicationController
  def index
    @database_memos = DatabaseMemo.all.includes(:data_source, :table_memos)
    redirect_to root_path
  end

  def show
    if params[:database_name]
      @database_memo = DatabaseMemo.includes(:table_memos).find_by!(name: params[:database_name])
    else
      @database_memo = DatabaseMemo.includes(:table_memos).find(params[:id])
    end
    @column_memo_names = ColumnMemo.where(table_memo_id: @database_memo.table_memos.map(&:id)).pluck(:table_memo_id, :name).each_with_object({}) do |row, hash|
      id, name = row
      (hash[id] ||= []) << name
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
