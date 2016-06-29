require "active_record/connection_adapters/redshift_adapter"

class DataSource < ActiveRecord::Base

  validates :name, :adapter, :host, :dbname, :user, presence: true

  has_many :ignored_tables

  module DynamicTable
    class AbstractTable < ActiveRecord::Base
      self.abstract_class = true

      class_attribute :defined_at, :schema_name

      def self.cache_key
        "#{name.underscore}-#{defined_at.strftime("%Y%m%d%H%M%S")}"
      end

      def self.access
        return yield if schema_name == "_"
        original_search_path = connection.schema_search_path
        begin
          connection.schema_cache.clear_table_cache!(table_name)
          connection.schema_search_path = schema_name
          yield
        ensure
          connection.schema_search_path = original_search_path
        end
      end
    end
  end

  def connection_config_password
    password.present? ? password : nil
  end

  def connection_config_encoding
    encoding.present? ? encoding : nil
  end

  def connection_config_pool
    pool.present? ? pool : nil
  end

  def connection_config
    {
      adapter: adapter,
      host: host,
      port: port,
      database: dbname,
      username: user,
      password: connection_config_password,
      encoding: connection_config_encoding,
      pool: connection_config_pool,
    }.compact
  end

  def source_table_class_name_prefix
    "#{name.gsub(/[^\w_-]/, '').underscore.classify}_"
  end

  def source_table_class_name(schema_name, table_name)
    "#{source_table_class_name_prefix}#{schema_name.classify}_#{table_name.classify}"
  end

  def source_base_class
    base_class_name = source_table_class_name("_", "Base")
    return DynamicTable.const_get(base_class_name) if DynamicTable.const_defined?(base_class_name)

    base_class = Class.new(DynamicTable::AbstractTable)
    DynamicTable.const_set(base_class_name, base_class)
    base_class.defined_at = Time.now
    base_class.abstract_class = true
    base_class.establish_connection(connection_config)
    base_class
  end

  def source_tables
    tables = case source_base_class.connection
      when ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, ActiveRecord::ConnectionAdapters::RedshiftAdapter
        source_base_class.connection.query(<<-SQL, 'SCHEMA')
          SELECT schemaname, tablename
          FROM (
            SELECT schemaname, tablename FROM pg_tables WHERE schemaname = ANY (current_schemas(false))
            UNION
            SELECT schemaname, viewname AS tablename FROM pg_views WHERE schemaname = ANY (current_schemas(false))
          ) tables
          ORDER BY schemaname, tablename;
        SQL
      else
        source_base_class.connection.tables.map {|table_name| ["_", table_name] }
    end
    tables.reject {|_, table_name| ignored_table_patterns.match(table_name) }
  end

  def cached_source_tables
    RequestStore.store["data_source_source_tables_#{id}"] ||= source_tables
  end

  def source_schema_names
    cached_source_tables.map {|table| table[0] }.uniq.sort
  end

  def source_table_class(schema_name, table_name, tables=source_tables)
    return if ignored_table_patterns.match(table_name)
    schema_name, _ = tables.find {|schema, table| schema == schema_name && table == table_name }
    return nil unless schema_name
    table_class_name = source_table_class_name(schema_name, table_name)
    return DynamicTable.const_get(table_class_name) if DynamicTable.const_defined?(table_class_name)
    table_class = Class.new(source_base_class)
    table_class.schema_name = schema_name
    table_class.table_name = table_name
    table_class.access do
      DynamicTable.const_set(table_class_name, table_class)
      table_class.defined_at = Time.now
      table_class
    end
  end

  def source_table_classes
    tables = source_tables
    tables.map do |schema_name, table_name|
      source_table_class(schema_name, table_name, tables)
    end
  end

  def reset_source_table_classes!
    DynamicTable.constants.select{|name| name.to_s.start_with?(source_table_class_name_prefix) }.each do |table_name|
      DynamicTable.send(:remove_const, table_name)
    end
  end

  def ignored_table_patterns
    @ignored_table_patterns ||= Regexp.union(ignored_tables.pluck(:pattern).map {|pattern| Regexp.new(pattern, true) })
  end
end
