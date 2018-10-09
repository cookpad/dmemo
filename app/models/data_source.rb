class DataSource < ApplicationRecord
  validates :name, :adapter, presence: true
  validates :host, :dbname, :user, presence: true, if: :standard_adapter?

  has_many :ignored_tables

  has_one :database_memo, class_name: "DatabaseMemo", foreign_key: :name, primary_key: :name, dependent: :destroy

  class ConnectionBad < IOError
  end

  def source_table_names
    table_names = access_logging { data_source_adapter.fetch_table_names }
    table_names.reject { |_, table_name| ignored_table_patterns.match(table_name) }
  end

  def data_source_table(schema_name, table_name, table_names)
    return if ignored_table_patterns.match(table_name)
    schema_name, _ = table_names.find {|schema, table| schema == schema_name && table == table_name }
    return nil unless schema_name
    DataSourceTable.new(self, schema_name, table_name)
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

  def data_source_adapter
    @data_source_adapter ||= DataSourceAdapters.adapters[adapter].new(self)
  end

  def standard_adapter?
    adapter.in? DataSourceAdapters.standard_adapter_names
  end
end
