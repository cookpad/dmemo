module DataSourceAdapters
  def self.adapters
    @adapters ||= {}
  end

  def self.register_adapter(adapter, name)
    adapters[name] = adapter
  end

  def self.adapter_names
    adapters.keys
  end

  def self.standard_adapter_names
    adapters.select { |_, adapter| adapter < StandardAdapter }.keys
  end
end
