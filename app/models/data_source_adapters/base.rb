module DataSourceAdapters
  class Base
    def initialize(data_source)
      @data_source = data_source
    end

    def fetch_schema_names
      raise NotImplementedError
    end

    def fetch_table_names
      raise NotImplementedError
    end

    def fetch_columns(table)
      raise NotImplementedError
    end

    def fetch_view_query(view)
      nil
    end

    def fetch_view_query_plan(query)
      raise NotImplementedError
    end

    def reset!
      raise NotImplementedError
    end
  end
end
