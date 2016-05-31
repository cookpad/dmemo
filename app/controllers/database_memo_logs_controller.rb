class DatabaseMemoLogsController < ApplicationController
  def index(database_memo_id)
    @database_memo = DatabaseMemo.find(database_memo_id)
    @database_memo_logs = @database_memo.database_memo_logs.reorder(id: :desc)
  end
end
