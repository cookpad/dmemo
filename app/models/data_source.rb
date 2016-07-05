require "active_record/connection_adapters/redshift_adapter"

class DataSource < ActiveRecord::Base

  validates :name, :adapter, :host, :dbname, :user, presence: true

  has_many :ignored_tables

  has_one :data_source, class_name: "DatabaseMemo", foreign_key: :name, primary_key: :name, dependent: :destroy

  after_save :disconnect_data_source!

  module DynamicTable
    class AbstractTable < ActiveRecord::Base
      self.abstract_class = true
    end
  end

  class ConnectionBad < IOError
  end

  def self.data_source_tables_cache
    @data_source_tables_cache ||= {}
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

  def source_base_class_name
    "#{name.gsub(/[^\w_-]/, '').underscore.classify}_Base"
  end

  def source_base_class
    base_class_name = source_base_class_name
    return DynamicTable.const_get(base_class_name) if DynamicTable.const_defined?(base_class_name)

    base_class = Class.new(DynamicTable::AbstractTable)
    DynamicTable.const_set(base_class_name, base_class)
    base_class.establish_connection(connection_config)
    base_class
  end

  def source_table_names
    table_names = case source_base_class.connection
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
    table_names.reject {|_, table_name| ignored_table_patterns.match(table_name) }
  rescue Mysql2::Error, PG::Error => e
    raise ConnectionBad.new(e)
  end

  def cache_key_source_table_names
    "data_source_source_table_names_#{id}"
  end

  def cached_source_table_names
    key = cache_key_source_table_names
    cache = Rails.cache.read(key)
    return cache if cache
    value = source_table_names
    Rails.cache.write(key, value)
    value
  end

  def data_source_table(schema_name, table_name, table_names=cached_source_table_names)
    return if ignored_table_patterns.match(table_name)
    schema_name, _ = table_names.find {|schema, table| schema == schema_name && table == table_name }
    return nil unless schema_name
    full_table_name = "#{schema_name}.#{table_name}"
    self.class.data_source_tables_cache[id] ||= {}
    source_table = self.class.data_source_tables_cache[id][full_table_name]
    return source_table if source_table
    self.class.data_source_tables_cache[id][full_table_name] = DataSourceTable.new(source_base_class, schema_name, table_name)
  rescue Mysql2::Error, PG::Error => e
    raise ConnectionBad.new(e)
  end

  def data_source_tables
    table_names = cached_source_table_names
    table_names.map do |schema_name, table_name|
      data_source_table(schema_name, table_name, table_names)
    end
  end

  def reset_data_source_tables!
    Rails.cache.delete(cache_key_source_table_names)
    self.class.data_source_tables_cache[id] = {}
    base_class_name = source_base_class_name
    DynamicTable.send(:remove_const, base_class_name) if DynamicTable.const_defined?(base_class_name)
  end

  def ignored_table_patterns
    @ignored_table_patterns ||= Regexp.union(ignored_tables.pluck(:pattern).map {|pattern| Regexp.new(pattern, true) })
  end

  def disconnect_data_source!
    source_base_class.establish_connection.disconnect!
  end
end
