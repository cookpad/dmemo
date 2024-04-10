require "rails_helper"

describe DataSourceAdapters::Mysql2Adapter, type: :model do
  let(:data_source) do
    FactoryBot.create(
      :data_source,
      adapter: 'mysql2',
      port: 3306,
      dbname: 'dmemo_test',
      user: 'root',
      password: '',
      host: '127.0.0.1',
    )
  end
  let(:adapter) { DataSourceAdapters::Mysql2Adapter.new(data_source) }
  let(:table) { DataSourceTable.new(data_source, 'dmemo_test', 'keywords') }

  def execute_sql(sql)
    sql.split(';').select(&:present?).each do |s|
      adapter.source_base_class.connection.execute(s)
    end
  end

  before do
    execute_sql(<<~SQL)
      CREATE TABLE IF NOT EXISTS #{table.table_name} (id INT PRIMARY KEY);
      TRUNCATE TABLE #{table.table_name};
      INSERT INTO #{table.table_name} VALUES (1);
      ANALYZE TABLE #{table.table_name};
    SQL
  end
end
