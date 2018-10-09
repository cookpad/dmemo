module DataSourceAdapters
  class << self
    def adapters
      @adapters ||= {}
    end

    def register_adapter(adapter, name)
      adapters[name] = adapter
    end

    def adapter_names
      adapters.keys
    end

    def standard_adapter_names
      adapters.select { |_, adapter| adapter < StandardAdapter }.keys
    end
  end
end
