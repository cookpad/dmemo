class KeywordsController < ApplicationController
  def show(keyword)
    table_memo = TableMemo.select(:id).find_by(name: keyword)
    redirect_to table_memo
  end
end
