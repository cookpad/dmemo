ActiveSupport.on_load(:active_record) do
  DataSourceAdapters.register_adapter(DataSourceAdapters::PostgresqlAdapter, 'postgresql')
  DataSourceAdapters.register_adapter(DataSourceAdapters::Mysql2Adapter, 'mysql2')
  DataSourceAdapters.register_adapter(DataSourceAdapters::RedshiftAdapter, 'redshift')
  DataSourceAdapters.register_adapter(DataSourceAdapters::BigqueryAdapter, 'bigquery')
  DataSourceAdapters.register_adapter(DataSourceAdapters::PrestoAdapter, 'presto')
end
