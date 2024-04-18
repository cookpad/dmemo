class SchemaMemosController < ApplicationController
  permits :description

  before_action :redirect_named_path, only: :show

  def show(database_name, name)
    @schema_memo = SchemaMemo.includes(table_memos: [:logs, :column_memos]).joins(:database_memo).merge(DatabaseMemo.where(name: database_name)).where(name:).take!
    redirect_to database_memo_path(@schema_memo.database_memo.name) if @schema_memo.single_schema?
  end

  def edit(id)
    @schema_memo = SchemaMemo.find(id)
  end

  def update(id, schema_memo)
    @schema_memo = SchemaMemo.find(id)
    @schema_memo.assign_attributes(schema_memo)
    if @schema_memo.changed?
      @schema_memo.build_log(current_user.id)
      @schema_memo.save!
    end
    redirect_to database_schema_path(@schema_memo.database_memo.name, @schema_memo.name)
  end

  def destroy(id)
    schema_memo = SchemaMemo.find(id)
    schema_memo.destroy!
    redirect_to database_memo_path(schema_memo.database_memo.name)
  end

  private

  def redirect_named_path(id = nil)
    return unless id =~ /\A\d+\z/
    schema_memo = SchemaMemo.find(id)
    redirect_to database_schema_path(schema_memo.database_memo.name, schema_memo.name)
  end
end
