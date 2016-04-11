class TableMemosController < ApplicationController
  def show
    @table_memo = TableMemo.find(params[:id])
  end
end
