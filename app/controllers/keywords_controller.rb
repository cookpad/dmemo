class KeywordsController < ApplicationController
  def show(keyword)
    if flash[:schema_memo_id]
      table_memo = TableMemo.find_by(schema_memo_id: flash[:schema_memo_id], name: keyword)
    elsif flash[:database_memo_id]
      schema_memo_ids = SchemaMemo.where(database_memo_id: flash[:database_memo_id]).pluck(:id)
      table_memo = TableMemo.find_by(schema_memo_id: schema_memo_ids, name: keyword)
    end
    unless table_memo
      table_memo = TableMemo.select(:id).find_by(name: keyword)
    end
    redirect_to table_memo
  end
end
