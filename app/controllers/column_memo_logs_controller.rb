class ColumnMemoLogsController < ApplicationController
  layout "colorbox"

  def index(column_memo_id)
    @column_memo = ColumnMemo.find(column_memo_id)
    @column_memo_logs = @column_memo.logs.reorder(id: :desc)
  end
end
