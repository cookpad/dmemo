class DataSourceTable
  attr_accessor :source_base_class, :schema_name, :table_name, :full_table_name, :columns, :defined_at

  delegate :connection, to: :source_base_class

  def initialize(source_base_class, schema_name, table_name)
    @source_base_class = source_base_class
    @schema_name = schema_name
    @table_name = table_name
    @full_table_name = schema_name == "_" ? table_name : "#{schema_name}.#{table_name}"
    @columns = connection.columns(full_table_name)
    @defined_at = Time.now
  end

  def cache_key
    "#{schema_name.underscore}-#{table_name.underscore}-#{defined_at.strftime("%Y%m%d%H%M%S")}"
  end

  def fetch_rows(limit=20)
    adapter = connection.pool.connections.first
    column_names = columns.map {|column| adapter.quote_column_name(column.name) }.join(", ")
    rows = connection.select_rows(<<-SQL, "#{table_name.classify} Load")
      SELECT #{column_names} FROM #{full_table_name} LIMIT #{limit};
    SQL
    rows.map {|row|
      columns.zip(row).map {|column, value| column.type_cast_from_database(value) }
    }
  end

  def fetch_count
    connection.select_value(<<-SQL).to_i
      SELECT COUNT(*) FROM #{full_table_name};
    SQL
  end
end
