class DataSource::Table
  attr_reader :name, :source_table_class

  def initialize(source_base_class, source_db_module, name)
    @name = name
    @source_table_class = Class.new(source_base_class)
    source_db_module.const_set(name.classify, @source_table_class)
    @source_table_class.table_name = name
  end
end
