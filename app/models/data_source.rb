require "active_record/connection_adapters/redshift_adapter"

class DataSource < ApplicationRecord

  validates :name, :adapter, :host, :dbname, :user, presence: true

  has_many :ignored_tables

  has_one :database_memo, class_name: "DatabaseMemo", foreign_key: :name, primary_key: :name, dependent: :destroy

  module DynamicTable
    class AbstractTable < ApplicationRecord
      self.abstract_class = true
    end
  end

  class ConnectionBad < IOError
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
    table_names = access_logging do
      case source_base_class.connection
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
          source_base_class.connection.tables.map {|table_name| [dbname, table_name] }
      end
    end
    table_names.reject {|_, table_name| ignored_table_patterns.match(table_name) }
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
    raise ConnectionBad.new(e)
  end

  def data_source_table(schema_name, table_name, table_names)
    return if ignored_table_patterns.match(table_name)
    schema_name, _ = table_names.find {|schema, table| schema == schema_name && table == table_name }
    return nil unless schema_name
    DataSourceTable.new(self, schema_name, table_name)
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error, PG::Error => e
    raise ConnectionBad.new(e)
  end

  def data_source_tables
    table_names = source_table_names
    table_names.map do |schema_name, table_name|
      data_source_table(schema_name, table_name, table_names)
    end
  end

  def ignored_table_patterns
    @ignored_table_patterns ||= Regexp.union(ignored_tables.pluck(:pattern).map {|pattern| Regexp.new(pattern, true) })
  end

  def access_logging
    Rails.logger.tagged("DataSource #{name}") { yield }
  end
end
