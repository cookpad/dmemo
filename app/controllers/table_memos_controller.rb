class TableMemosController < ApplicationController
  permits :description

  before_action :redirect_named_path, only: :show

  def show(database_name, schema_name, name)
    @table_memo = TableMemo.
      includes(column_memos: :logs).
      joins(:schema_memo).
      merge(SchemaMemo.where(name: schema_name).joins(:database_memo).merge(DatabaseMemo.where(name: database_name))).
      where(name: name).
      take!
    @raw_dataset = @table_memo.raw_dataset
    if @raw_dataset
      @masked_columns = MaskedDatum.masked_columns(database_name, name)
      @raw_dataset_columns = @raw_dataset.columns.order(:position).map { |column| {
        data: column,
        masked: @masked_columns.include?(::MaskedDatum::ANY_NAME) || @masked_columns.include?(column.name),
      }}
      @raw_dataset_rows = @raw_dataset.rows.pluck(:row)
    end
    @view_meta_data = @table_memo.view_meta_data
  end

  def edit(id)
    @table_memo = TableMemo.find(id)
  end

  def update(id, table_memo)
    @table_memo = TableMemo.find(id)
    @table_memo.assign_attributes(table_memo)
    if @table_memo.changed?
      @table_memo.build_log(current_user.id)
      @table_memo.save!
    end
    redirect_to database_schema_table_path(@table_memo.database_memo.name, @table_memo.schema_memo.name, @table_memo.name)
  end

  def destroy(id)
    table_memo = TableMemo.find(id)
    table_memo.destroy!
    redirect_to database_memo_path(table_memo.database_memo.name)
  end

  private

  def redirect_named_path(id = nil)
    return unless id =~ /\A\d+\z/
    table_memo = TableMemo.find(id)
    redirect_to database_schema_table_path(table_memo.database_memo.name, table_memo.schema_memo.name, table_memo.name)
  end
end
