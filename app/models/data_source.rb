class DataSource < ActiveRecord::Base

  validates :name, :adapter, :host, :dbname, :user, presence: true

  module DynamicTable
    class AbstractTable < ActiveRecord::Base
      self.abstract_class = true

      class_attribute :defined_at

      def self.cache_key
        "#{name.underscore}-#{defined_at.strftime("%Y%m%d%H%M%S")}"
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

  def source_table_class_name(table_name)
    "#{source_table_class_name_prefix}#{table_name.classify}"
  end

  def source_base_class
    base_class_name = source_table_class_name("Base")
    return DynamicTable.const_get(base_class_name) if DynamicTable.const_defined?(base_class_name)

    base_class = Class.new(DynamicTable::AbstractTable)
    DynamicTable.const_set(base_class_name, base_class)
    base_class.defined_at = Time.now
    base_class.abstract_class = true
    base_class.establish_connection(connection_config)
    base_class
  end

  def source_table_names
    source_base_class.connection.tables
  end

  def source_table_class(table_name, table_names)
    table_class_name = source_table_class_name(table_name)
    return DynamicTable.const_get(table_class_name) if DynamicTable.const_defined?(table_class_name)
    return nil unless table_names.include?(table_name)
    table_class = Class.new(source_base_class)
    table_class.table_name = table_name
    DynamicTable.const_set(table_class_name, table_class)
    table_class.defined_at = Time.now
    table_class
  end

  def source_table_classes
    table_names = source_table_names
    table_names.map do |table_name|
      source_table_class(table_name, table_names)
    end
  end

  def reset_source_table_classes!
    DynamicTable.constants.select{|name| name.to_s.start_with?(source_table_class_name_prefix) }.each do |table_name|
      DynamicTable.send(:remove_const, table_name)
    end
  end
end
