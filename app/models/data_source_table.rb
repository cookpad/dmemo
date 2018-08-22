class DataSourceTable
  attr_reader :data_source, :schema_name, :table_name, :full_table_name, :columns, :defined_at

  delegate :source_base_class, to: :data_source
  delegate :connection, to: :source_base_class

  def initialize(data_source, schema_name, table_name)
    @data_source = data_source
    @schema_name = schema_name
    @table_name = table_name
    @full_table_name = "#{schema_name}.#{table_name}"
    @columns = data_source.access_logging { connection.columns(full_table_name) }
    @defined_at = Time.now
  end

  def fetch_rows(limit=20)
    data_source.access_logging do
      adapter = connection.pool.connections.first
      column_names = columns.map {|column| adapter.quote_column_name(column.name) }.join(", ")
      rows = connection.select_rows(<<-SQL, "#{table_name.classify} Load")
        SELECT #{column_names} FROM #{adapter.quote_table_name(full_table_name)} LIMIT #{limit};
      SQL
      rows.map {|row|
        columns.zip(row).map {|column, value| adapter.type_cast(value, column) }
      }
    end
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
    raise DataSource::ConnectionBad.new(e)
  end

  def fetch_count
    data_source.access_logging do
      adapter = connection.pool.connections.first
      connection.select_value(<<-SQL).to_i
        SELECT COUNT(*) FROM #{adapter.quote_table_name(full_table_name)};
      SQL
    end
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
    raise DataSource::ConnectionBad.new(e)
  end
end
