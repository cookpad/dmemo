class DataSource < ActiveRecord::Base

  module DynamicTable
  end

  def connection_config
    {
        adapter: adapter,
        host: host,
        port: port,
        database: dbname,
        username: user,
        password: password,
        encoding: encoding,
        pool: pool,
    }.compact
  end

  def source_table_class_name_prefix
    "#{name.classify}_"
  end

  def source_table_class_name(table_name)
    "#{source_table_class_name_prefix}#{table_name.classify}"
  end

  def source_base_class
    base_class_name = source_table_class_name("Base")
    return DynamicTable.const_get(base_class_name) if DynamicTable.const_defined?(base_class_name)

    base_class = Class.new(ActiveRecord::Base)
    DynamicTable.const_set(base_class_name, base_class)
    base_class.abstract_class = true
    base_class.establish_connection(connection_config)
    base_class
  end

  def source_table_names
    source_base_class.connection.tables
  end

  def source_table_class(table_name)
    table_class_name = source_table_class_name(table_name)
    return DynamicTable.const_get(table_class_name) if DynamicTable.const_defined?(table_class_name)
    return nil unless source_table_names.include?(table_name)
    table_class = Class.new(source_base_class)
    table_class.table_name = table_name
    DynamicTable.const_set(table_class_name, table_class)
  end

  def source_table_classes
    source_table_names.map do |table_name|
      source_table_class(table_name)
    end
  end

  def reset_source_table_classes!
    DynamicTable.constants.select{|name| name.to_s.start_with?(source_table_class_name_prefix) }.each do |table_name|
      DynamicTable.send(:remove_const, table_name)
    end
  end
end
