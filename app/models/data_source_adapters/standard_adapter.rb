module DataSourceAdapters
  class StandardAdapter < Base
    def fetch_schema_names
      raise NotImplementedError
    end

    def fetch_table_names
      raise NotImplementedError
    end

    def fetch_columns(table)
      with_connection do |conn|
        conn.columns(table.full_table_name).map { |c| Column.new(c.name, c.sql_type, conn.quote(c.default), c.null) }
      end
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_view_query_plan(query)
      with_connection do |conn|
        conn.query("EXPLAIN #{query}", 'EXPLAIN').join("\n")
      end
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

    def with_connection(&block)
      source_base_class.with_connection(&block)
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
