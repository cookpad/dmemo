class DataSource < ActiveRecord::Base

  module DynamicTable
  end

  def source_db_module
    return @source_db_module if @source_db_module

    @source_db_module = Module.new
    DynamicTable.const_set(dbname.classify, @source_db_module)
  end

  def source_base_class
    return @source_base_class if @source_base_class

    @source_base_class = Class.new(ActiveRecord::Base)
    source_db_module.const_set("Base", @source_base_class)
    @source_base_class.establish_connection(
      adapter: adapter,
      host: host,
      port: port,
      username: user,
      password: password,
      database: dbname,
    )
  end

  def tables
    source_base_class.connection.tables.map do |name|
      DataSource::Table.new(source_base_class, source_db_module, name)
    end
  end
end
