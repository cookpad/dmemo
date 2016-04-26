require "active_record/connection_adapters/postgresql_adapter"
require "active_record/connection_adapters/redshift_adapter"

module ActiveRecord::ConnectionAdapters

  class PostgreSQLAdapter
    def tables_with_views
      views = query(<<-SQL, 'SCHEMA').map { |row| row[0] }
        SELECT viewname
          FROM pg_views
          WHERE schemaname = ANY (current_schemas(false))
      SQL
      (tables_without_views + views).sort
    end

    alias_method_chain :tables, :views
  end

  class RedshiftAdapter
    def tables_with_views
      views = query(<<-SQL, 'SCHEMA').map { |row| row[0] }
        SELECT viewname
          FROM pg_views
          WHERE schemaname = ANY (current_schemas(false))
      SQL
      (tables_without_views + views).sort
    end

    alias_method_chain :tables, :views
  end
end
