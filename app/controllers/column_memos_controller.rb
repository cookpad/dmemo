class ColumnMemosController < ApplicationController
  permits :description

  skip_before_action :set_sidebar_databases, :set_search_result

  def show(id)
    @column_memo = ColumnMemo.find(id)
    redirect_to @column_memo.table_memo
  end

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
    redirect_to database_schema_table_path(@column_memo.database_memo.name, @column_memo.schema_memo.name, @column_memo.table_memo.name)
  end

  def destroy(id)
    column_memo = ColumnMemo.find(id)
    column_memo.destroy!
    redirect_to table_memo_path(column_memo.table_memo_id)
  end
end
