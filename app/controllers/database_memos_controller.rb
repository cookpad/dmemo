class DatabaseMemosController < ApplicationController
  permits :description

  before_action :redirect_named_path, only: :show

  def index
    @database_memos = DatabaseMemo.all.includes(:data_source, :table_memos)
    redirect_to root_path
  end

  def show(id)
    @database_memo = DatabaseMemo.where(name: id).includes(:table_memos).take!
    @column_memo_names = ColumnMemo.where(table_memo_id: @database_memo.table_memos.map(&:id)).pluck(:table_memo_id, :name).each_with_object({}) do |row, hash|
      id, name = row
      (hash[id] ||= []) << name
    end
  end

  def edit(id)
    @database_memo = DatabaseMemo.find(id)
    @column_memo_names = ColumnMemo.where(table_memo_id: @database_memo.table_memos.map(&:id)).pluck(:table_memo_id, :name).each_with_object({}) do |row, hash|
      id, name = row
      (hash[id] ||= []) << name
    end
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
