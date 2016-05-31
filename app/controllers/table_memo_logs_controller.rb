class TableMemoLogsController < ApplicationController
  def index(table_memo_id)
    @table_memo = TableMemo.find(table_memo_id)
    @table_memo_logs = @table_memo.table_memo_logs.reorder(id: :desc)
  end
end
