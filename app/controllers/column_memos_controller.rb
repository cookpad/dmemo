class ColumnMemosController < ApplicationController
  def update
    @column_memo = ColumnMemo.find(params[:id])
    case params[:name]
      when "description"
        @column_memo.update!(description: params[:value])
    end
  end

  def destroy
    column_memo = ColumnMemo.find(params[:id])
    column_memo.destroy!
    redirect_to table_memo_path(column_memo.table_memo_id)
  end
end
