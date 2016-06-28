class SchemaMemoLogsController < ApplicationController
  def index(schema_memo_id)
    @schema_memo = SchemaMemo.find(schema_memo_id)
    @schema_memo_logs = @schema_memo.logs.reorder(id: :desc)
  end
end
