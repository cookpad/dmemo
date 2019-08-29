require "active_record/connection_adapters/redshift_adapter"

module DataSourceAdapters
  class RedshiftAdapter < StandardAdapter
    def fetch_table_names
      query_result = source_base_class.connection.query(<<~SQL, 'SCHEMA')
        SELECT table_schema, table_name, table_type
        FROM (
          SELECT table_schema, table_name, table_type
          FROM svv_tables
          WHERE table_schema = ANY (current_schemas(false)) or table_type = 'EXTERNAL TABLE'

          UNION

          SELECT DISTINCT view_schema, view_name, 'LATE BINDING'
          FROM pg_get_late_binding_view_cols() cols(view_schema name, view_name name, col_name name, col_type varchar, col_num int)
          WHERE view_schema = ANY (current_schemas(false))
        ) tables
        ORDER BY table_schema, table_name;
      SQL

      table_groups = group_by_table_type(query_result)

      @base_table_names = table_groups['BASE TABLE'] || []
      @external_table_names = table_groups['EXTERNAL TABLE'] || []
      @view_names = table_groups['VIEW'] || []
      @late_binding_view_names = table_groups['LATE BINDING'] || []

      (@base_table_names + @external_table_names + @view_names + @late_binding_view_names).uniq
    rescue ActiveRecord::ActiveRecordError, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_columns(table)
      adapter = connection.pool.connection
      connection.query(<<~SQL, 'COLUMN').map { |name, sql_type, default, nullable| Column.new(name, sql_type, adapter.quote(default), nullable || false) }
        SELECT column_name, data_type, column_default, is_nullable FROM svv_columns WHERE table_schema = '#{table.schema_name}' and table_name = '#{table.table_name}';
      SQL
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_rows(table, limit)
      return [] if late_binding_view?(table)
      return fetch_spectrum_rows(table, limit) if spectrum?(table)
      super
    end

    def fetch_spectrum_rows(table, limit)
      adapter = connection.pool.connection
      rows = connection.select_rows(<<~SQL, "#{table.full_table_name.classify} Load")
        SELECT * FROM #{adapter.quote_table_name(table.full_table_name)} LIMIT #{limit};
      SQL
    rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_count(table)
      return 0 if late_binding_view?(table)
      super
    end

    def fetch_view_query(table)
      return nil unless view?(table)
      adapter = connection.pool.connection
      connection.query(<<~SQL, 'VIEW QUERY').join("\n")
        SELECT definition FROM pg_views WHERE schemaname = '#{table.schema_name}' and viewname = '#{table.table_name}';
      SQL
    end

    def fetch_view_query_plan(query)
      return nil if query.blank?
      query = query.sub(/create view .*?as/, '').sub('with no schema binding', '')
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

    def view?(table)
      base_view?(table) || late_binding_view?(table)
    end

    def base_view?(table)
      raise "@view_names must be defined, execute fetch_table befor view?" unless instance_variable_defined?(:@view_names)
      @view_names.include?(table.full_table_name.split('.'))
    end

    def late_binding_view?(table)
      raise "@late_binding_view_names must be defined, execute fetch_table befor late_binding_view?" unless instance_variable_defined?(:@late_binding_view_names)
      @late_binding_view_names.include?(table.full_table_name.split('.'))
    end
  end
end
