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
  end
end
