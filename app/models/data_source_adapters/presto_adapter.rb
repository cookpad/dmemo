module DataSourceAdapters
  class PrestoAdapter < TrinoAdapter
    DataSourceAdapters.register_adapter(self, 'presto')

    # trino-client sends X-Presto-* headers when model_version is less than 351.
    # 316 is the default model version of presto-client.
    PRESTO_MODEL_VERSION = 316

    private

    def connection_config
      super.merge(model_version: PRESTO_MODEL_VERSION)
    end
  end
end
