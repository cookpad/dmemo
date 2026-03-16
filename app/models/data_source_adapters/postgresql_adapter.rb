module DataSourceAdapters
  class PostgresqlAdapter < StandardAdapter
    def fetch_schema_names
      @schema_names ||= with_connection do |conn|
        conn.query(<<~SQL, 'SCHEMA')
          SELECT nspname as schema_name, usename as owner_name
          FROM pg_catalog.pg_namespace s join pg_catalog.pg_user u on u.usesysid = s.nspowner
          ORDER BY schema_name;
        SQL
      end
    end

    def fetch_table_names
      with_connection do |conn|
        conn.query(<<~SQL, 'SCHEMA')
          SELECT schemaname, tablename
          FROM (
            SELECT schemaname, tablename FROM pg_tables
            UNION
            SELECT schemaname, viewname AS tablename FROM pg_views
          ) tables
          WHERE schemaname not in ('pg_catalog', 'information_schema')
          ORDER BY schemaname, tablename;
        SQL
      end
    rescue ActiveRecord::ActiveRecordError, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end
  end
end
