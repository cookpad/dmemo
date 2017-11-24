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
      decode_with = data_source.encoding or 'UTF-8'
      encode_to = Encoding.default_internal or 'UTF-8'
      column_names = columns.map {|column| adapter.quote_column_name(column.name.encode(encode_to, decode_with)) }.join(", ")
      if data_source[:adapter] == 'sqlserver'
        rows = connection.select_rows(<<-SQL, "#{table_name.classify} Load")
          SELECT TOP #{limit} #{column_names} FROM #{adapter.quote_table_name(full_table_name)};
        SQL
      else
        rows = connection.select_rows(<<-SQL, "#{table_name.classify} Load")
          SELECT #{column_names} FROM #{adapter.quote_table_name(full_table_name)} LIMIT #{limit};
        SQL
      end
      rows.map {|row|
        columns.zip(row).map {|column, value| column.type_cast_from_database(value) }
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
