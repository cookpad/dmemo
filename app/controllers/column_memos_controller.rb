class ColumnMemosController < ApplicationController
  def update(id, name, value)
    @column_memo = ColumnMemo.find(id)
    case name
      when "description"
        @column_memo.assign_attributes(description: value)
    end
    if @column_memo.changed?
      @column_memo.build_log(current_user.id)
      @column_memo.save!
    end
  end

  def destroy(id)
    column_memo = ColumnMemo.find(id)
    column_memo.destroy!
    redirect_to table_memo_path(column_memo.table_memo_id)
  end
end
