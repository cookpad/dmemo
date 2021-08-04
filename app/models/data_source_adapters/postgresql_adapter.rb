module DataSourceAdapters
  class PostgresqlAdapter < StandardAdapter
    def fetch_schema_names
      @schema_names ||= source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT nspname as schema_name, usename as owner_name
        FROM pg_catalog.pg_namespace s join pg_catalog.pg_user u on u.usesysid = s.nspowner
        ORDER BY schema_name;
      SQL
    end

    def fetch_table_names
      source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT schemaname, tablename
        FROM (
          SELECT schemaname, tablename FROM pg_tables
          UNION
          SELECT schemaname, viewname AS tablename FROM pg_views
        ) tables
        ORDER BY schemaname, tablename;
      SQL
    rescue ActiveRecord::ActiveRecordError, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
