class ColumnMemosController < ApplicationController
  def update(id, name, value)
    @column_memo = ColumnMemo.find(id)
    case name
      when "description"
        @column_memo.update!(description: value)
    end
  end

  def destroy(id)
    column_memo = ColumnMemo.find(id)
    column_memo.destroy!
    redirect_to table_memo_path(column_memo.table_memo_id)
  end
end
