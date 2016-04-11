class DataSource < ActiveRecord::Base

  module DynamicTable
  end

  def source_db_module
    return DataSource.const_get(dbname.classify) if DataSource.const_defined?(dbname.classify)

    db_module = Module.new
    DynamicTable.const_set(dbname.classify, db_module)
  end

  def source_base_class
    return source_db_module.const_get("Base") if source_db_module.const_defined?("Base")

    base_class = Class.new(ActiveRecord::Base)
    source_db_module.const_set("Base", base_class)
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

  def source_tables
    source_base_class.connection.tables.map do |name|
      fetch_or_define_table_class(source_base_class, source_db_module, name.classify)
    end
  end

  private

  def fetch_or_define_table_class(base_class, db_module, name)
    return db_module.const_get(name) if db_module.const_defined?(name)
    table_class = Class.new(base_class)
    db_module.const_set(name, table_class)
  end
end
