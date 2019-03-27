require "active_record/connection_adapters/redshift_adapter"

module DataSourceAdapters
  class RedshiftAdapter < StandardAdapter
    def fetch_table_names
      query_result = source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT table_schema, table_name, table_type
        FROM (
          SELECT table_schema, table_name, table_type FROM svv_tables WHERE table_schema = ANY (current_schemas(false)) or table_type = 'EXTERNAL TABLE'
          UNION
          SELECT schemaname as table_schema, viewname AS table_name, 'VIEW' FROM pg_views WHERE schemaname = ANY (current_schemas(false))
        ) tables
        ORDER BY table_schema, table_name;
      SQL

      table_groups = group_by_table_type(query_result)

      @base_table_names = table_groups['BASE TABLE'] || []
      @external_table_names = table_groups['EXTERNAL TABLE'] || []
      @view_names = table_groups['VIEW'] || []

      (@base_table_names + @external_table_names + @view_names).uniq
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

    def group_by_table_type(records)
      records.group_by { |r| r[2] }.map { |k, v| [k, reject_table_type(v)] }.to_h
    end

    def reject_table_type(records)
      records.map { |r| [r[0], r[1]] }
    end

    def spectrum?(table)
      raise "@external_table_names must be defined, execute fetch_table befor spectrum?" unless instance_variable_defined?(:@external_table_names)
      @external_table_names.include?(table.full_table_name.split('.'))
    end
  end
end
