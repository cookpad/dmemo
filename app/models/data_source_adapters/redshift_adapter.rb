require "active_record/connection_adapters/redshift_adapter"

module DataSourceAdapters
  class RedshiftAdapter < StandardAdapter
    def fetch_table_names
      @table_names = source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT schemaname, tablename
        FROM (
          SELECT schemaname, tablename FROM pg_tables WHERE schemaname = ANY (current_schemas(false))
          UNION
          SELECT schemaname, viewname AS tablename FROM pg_views WHERE schemaname = ANY (current_schemas(false))
        ) tables
        ORDER BY schemaname, tablename;
      SQL

      @external_table_names = source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT schemaname, tablename FROM svv_external_tables ORDER BY schemaname, tablename;
      SQL

      @table_names + @external_table_names
    rescue ActiveRecord::ActiveRecordError, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_columns(table)
      adapter = connection.pool.connection
      if spectrum?(table)
        connection.query(<<~SQL, 'COLUMN').map { |name, sql_type| Column.new(name, sql_type, "NULL", true) }
          SELECT columnname, external_type FROM svv_external_columns WHERE tablename = '#{table.table_name}';
        SQL
      else
        connection.columns(table.full_table_name).map { |c| Column.new(c.name, c.sql_type, adapter.quote(c.default), c.null) }
      end
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_rows(table, limit)
      return [] if spectrum?(table)
      super
    end

    def fetch_count(table)
      return 0 if spectrum?(table)
      super
    end

    private

    def spectrum?(table)
      @external_table_names.include?(table.full_table_name.split('.'))
    end
  end
end
