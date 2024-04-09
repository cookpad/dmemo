class DataSourceTable
  attr_reader :data_source, :schema_name, :table_name, :full_table_name, :defined_at

  delegate :data_source_adapter, to: :data_source

  def initialize(data_source, schema_name, table_name)
    @data_source = data_source
    @schema_name = schema_name
    @table_name = table_name
    @full_table_name = "#{schema_name}.#{table_name}"
    @defined_at = Time.now
  end

  def columns
    @columns ||= data_source.access_logging { data_source_adapter.fetch_columns(self) }
  end

  def fetch_view_query
    @view_query ||= @data_source.access_logging { data_source_adapter.fetch_view_query(self) }
  end

  def fetch_view_query_plan
    @view_query_plan ||= @data_source.access_logging { data_source_adapter.fetch_view_query_plan(@view_query) }
  end
end
