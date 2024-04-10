module DataSourceAdapters
  class RedshiftAdapter < StandardAdapter
    def fetch_schema_names
      @schema_names ||= exec_query(<<~SQL)
        SELECT nspname as schema_name, usename as owner_name
        FROM pg_catalog.pg_namespace s join pg_catalog.pg_user u on u.usesysid = s.nspowner
        WHERE usename != 'rdsdb'
        ORDER BY schema_name;
      SQL
    end

    def fetch_table_names
      query_result = exec_query(<<~SQL)
        SELECT table_schema, table_name, table_type
        FROM (
          SELECT table_schema, table_name, table_type
          FROM svv_tables

          UNION

          SELECT DISTINCT view_schema, view_name, 'LATE BINDING'
          FROM pg_get_late_binding_view_cols() cols(view_schema name, view_name name, col_name name, col_type varchar, col_num int)
        ) tables
        WHERE table_schema not in ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name;
      SQL

      table_groups = group_by_table_type(query_result)

      @base_table_names = table_groups['BASE TABLE'] || []
      @external_table_names = table_groups['EXTERNAL TABLE'] || []
      @view_names = table_groups['VIEW'] || []
      @late_binding_view_names = table_groups['LATE BINDING'] || []

      (@base_table_names + @external_table_names + @view_names + @late_binding_view_names).uniq
    rescue PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_columns(table)
      query = <<~SQL
        SELECT column_name, data_type, column_default, is_nullable, character_maximum_length
        FROM svv_columns
        WHERE table_schema = '#{table.schema_name}' and table_name = '#{table.table_name}'
        ORDER BY ordinal_position;
      SQL
      exec_query(query).map do |name, sql_type, default, nullable, char_length|
        is_nullable =
          if spectrum?(table)
            # FIXME: could not get nullable info from Spectrum table
            true
          else
            # is_nullable column in svv_columns contains 'YES' or 'NO' or null.
            # It must be correctly converted to a boolean.
            case nullable
            when 'YES'
              true
            when 'NO'
              false
            else
              false
            end
          end
        column_type = sql_type == 'character varying' ? "varchar(#{char_length})" : sql_type
        Column.new(name, column_type, default.nil? ? 'NULL' : default, is_nullable)
      end
    rescue PG::Error => e
      raise DataSource::ConnectionBad.new(e)
    end

    def fetch_view_query(table)
      return nil unless view?(table)
      exec_query(<<~SQL).join("\n")
        SELECT definition FROM pg_views WHERE schemaname = '#{table.schema_name}' and viewname = '#{table.table_name}';
      SQL
    end

    def fetch_view_query_plan(query)
      return nil if query.blank?
      # to explain, extract of select statement from view query without 'with no schema binding'
      query = query.match(/select(.|\n)+/i)[0].sub(/\)? ?with no schema binding/, '')
      exec_query("EXPLAIN #{query}").join("\n")
    end

    def reset!
      # We don't use any transactions for Redshift, so it's enough to just remove the source base class.
      DynamicTable.send(:remove_const, source_base_class_name) if DynamicTable.const_defined?(source_base_class_name)
    end

    private

    def connection_config
      {
        host: @data_source.host,
        port: @data_source.port,
        dbname: @data_source.dbname,
        user: @data_source.user,
        password: @data_source.password,
        client_encoding: @data_source.encoding,
      }.compact
    end

    def connection
      @connection ||= PG.connect(connection_config)
    end

    def exec_query(query)
      Rails.logger.info(query)
      connection.exec(query).values
    end

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
