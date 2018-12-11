module DataSourceAdapters
  class Base
    def initialize(data_source)
      @data_source = data_source
    end

    def fetch_table_names
      raise NotImplementedError
    end

    def fetch_columns(table)
      raise NotImplementedError
    end

    def fetch_rows(table, limit)
      raise NotImplementedError
    end

    def fetch_count(table)
      raise NotImplementedError
    end

    def reset!
      raise NotImplementedError
    end
  end
end
