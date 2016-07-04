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
    return unless @table_memo.linked?
    begin
      data_source_table = @table_memo.data_source_table
      if data_source_table
        @source_column_classes = data_source_table.columns
        unless @table_memo.masked?
          @source_table_data = fetch_source_table_data(data_source_table)
        end
        @source_table_count = fetch_source_table_count(data_source_table)
      else
        @table_memo.update!(linked: false)
        flash[:error] = "#{@table_memo.schema_memo.name}.#{@table_memo.name} table not found"
      end
    rescue DataSource::ConnectionBad => e
      @connection_error = e.message
    end
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

  def fetch_source_table_count(data_source_table)
    cache("source_table_count_#{data_source_table.cache_key}", expire: 1.day) do
      data_source_table.fetch_count
    end
  end

  def fetch_source_table_data(data_source_table)
    cache("source_table_data_#{data_source_table.cache_key}", expire: 1.day) do
      data_source_table.fetch_rows
    end
  end

  private

  def redirect_named_path(id = nil)
    return unless id =~ /\A\d+\z/
    table_memo = TableMemo.find(id)
    redirect_to database_schema_table_path(table_memo.database_memo.name, table_memo.schema_memo.name, table_memo.name)
  end
end
