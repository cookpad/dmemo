class DatabaseMemosController < ApplicationController
  def index
    redirect_to root_path
  end

  def show
    @database_memo = DatabaseMemo.includes(table_memos: :column_memos).find(params[:id])
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
