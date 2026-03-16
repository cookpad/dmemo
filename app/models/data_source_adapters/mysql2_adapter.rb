module DataSourceAdapters
  class Mysql2Adapter < StandardAdapter
    def fetch_schema_names
      @schema_names ||= [[@data_source.dbname, 'unknown']]
    end

    def fetch_table_names
      with_connection { |conn| conn.tables.map { |table_name| [@data_source.dbname, table_name] } }
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
