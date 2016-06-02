class ColumnMemosController < ApplicationController
  permits :description

  def edit(id)
    @column_memo = ColumnMemo.find(id)
    render layout: "colorbox"
  end

  def update(id, column_memo)
    @column_memo = ColumnMemo.find(id)
    @column_memo.assign_attributes(column_memo)
    if @column_memo.changed?
      @column_memo.build_log(current_user.id)
      @column_memo.save!
    end
    redirect_to database_memo_table_path(@column_memo.table_memo.database_memo.name, @column_memo.table_memo.name)
  end

  def destroy(id)
    column_memo = ColumnMemo.find(id)
    column_memo.destroy!
    redirect_to table_memo_path(column_memo.table_memo_id)
  end
end
