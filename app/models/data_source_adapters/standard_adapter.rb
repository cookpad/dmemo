module DataSourceAdapters
  class StandardAdapter < Base
    def fetch_table_names
      raise NotImplementedError
    end

    def fetch_columns(table)
      adapter = connection.pool.connection
      raw_columns(table).map { |c| Column.new(c.name, c.sql_type, adapter.quote(c.default), c.null) }
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_rows(table, limit)
      adapter = connection.pool.connection
      column_names = raw_columns(table).map { |column| adapter.quote_column_name(column.name) }.join(", ")
      rows = connection.select_rows(<<-SQL, "#{table.full_table_name.classify} Load")
        SELECT #{column_names} FROM #{adapter.quote_table_name(table.full_table_name)} LIMIT #{limit};
      SQL
      rows.map {|row|
        raw_columns(table).zip(row).map {|column, value| adapter.type_cast(value, column) }
      }
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_count(table)
      adapter = connection.pool.connection
      connection.select_value(<<-SQL).to_i
        SELECT COUNT(*) FROM #{adapter.quote_table_name(table.full_table_name)};
      SQL
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def source_base_class
      return DynamicTable.const_get(source_base_class_name) if DynamicTable.const_defined?(source_base_class_name)

      base_class = Class.new(DynamicTable::AbstractTable)
      DynamicTable.const_set(source_base_class_name, base_class)
      base_class.establish_connection(connection_config)
      base_class
    end

    def reset!
      source_base_class.establish_connection.disconnect!
      DynamicTable.send(:remove_const, source_base_class_name) if DynamicTable.const_defined?(source_base_class_name)
    end

    private

    def raw_columns(table)
      connection.columns(table.full_table_name)
    end

    def connection
      source_base_class.connection
    end

    def source_base_class_name
      "#{@data_source.name.gsub(/[^\w_-]/, '').underscore.classify}_Base"
    end

    def connection_config
      {
        adapter: @data_source.adapter,
        host: @data_source.host,
        port: @data_source.port,
        database: @data_source.dbname,
        username: @data_source.user,
        password: @data_source.password.presence,
        encoding: @data_source.encoding.presence,
        pool: @data_source.pool.presence,
      }.compact
    end
  end
end
