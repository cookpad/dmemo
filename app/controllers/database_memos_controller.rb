class DatabaseMemosController < ApplicationController
  permits :description

  before_action :redirect_named_path, only: :show

  def index
    redirect_to root_path
  end

  def show(id)
    @database_memo = DatabaseMemo.where(name: id).includes(schema_memos: { table_memos: :column_memos }).take!
  end

  def edit(id)
    @database_memo = DatabaseMemo.find(id)
  end

  def update(id, database_memo)
    @database_memo = DatabaseMemo.find(id)
    @database_memo.assign_attributes(database_memo)
    if @database_memo.changed?
      @database_memo.build_log(current_user.id)
      @database_memo.save!
    end
    redirect_to database_memo_path(@database_memo.name)
  end

  def destroy(id)
    database_memo = DatabaseMemo.find(id)
    database_memo.destroy!
    redirect_to root_path
  end

  private

  def redirect_named_path(id = nil)
    return unless id =~ /\A\d+\z/
    redirect_to database_memo_path(DatabaseMemo.where(id: id).pluck(:name).first)
  end
end
