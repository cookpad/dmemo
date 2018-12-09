require "active_record/connection_adapters/redshift_adapter"

module DataSourceAdapters
  class RedshiftAdapter < StandardAdapter
    def fetch_table_names
      source_base_class.connection.query(<<-SQL, 'SCHEMA')
        SELECT schemaname, tablename
        FROM (
          SELECT schemaname, tablename FROM pg_tables WHERE schemaname = ANY (current_schemas(false))
          UNION
          SELECT schemaname, viewname AS tablename FROM pg_views WHERE schemaname = ANY (current_schemas(false))
        ) tables
        ORDER BY schemaname, tablename;
      SQL
    rescue ActiveRecord::ActiveRecordError, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
