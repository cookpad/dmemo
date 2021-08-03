module DataSourceAdapters
  class Mysql2Adapter < StandardAdapter
    def fetch_schema_names
      @schema_names ||= [[@data_source.dbname, 'unknown']]
    end

    def fetch_table_names
      source_base_class.connection.tables.map { |table_name| [@data_source.dbname, table_name] }
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_count(table)
      adapter = connection.pool.connection
      connection.select_value(<<-SQL).to_i
        SELECT TABLE_ROWS
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = #{adapter.quote(table.schema_name)} AND TABLE_NAME = #{adapter.quote(table.table_name)};
      SQL
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
