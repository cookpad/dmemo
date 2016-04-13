class DataSource < ActiveRecord::Base

  module DynamicTable
  end

  def source_table_class_name(name)
    "#{dbname.classify}_#{name.classify}"
  end

  def source_base_class
    base_class_name = source_table_class_name("Base")
    return DynamicTable.const_get(base_class_name) if DynamicTable.const_defined?(base_class_name)

    base_class = Class.new(ActiveRecord::Base)
    DynamicTable.const_set(base_class_name, base_class)
    base_class.establish_connection(
      adapter: adapter,
      host: host,
      port: port,
      username: user,
      password: password,
      database: dbname,
    )

    base_class
  end

  def source_table_class(table_name)
    table_class_name = source_table_class_name(table_name)
    return DynamicTable.const_get(table_class_name) if DynamicTable.const_defined?(table_class_name)
    table_class = Class.new(source_base_class)
    table_class.table_name = table_name
    DynamicTable.const_set(table_class_name, table_class)
  end

  def source_table_classes
    source_base_class.connection.tables.map do |table_name|
      source_table_class(table_name)
    end
  end
end
