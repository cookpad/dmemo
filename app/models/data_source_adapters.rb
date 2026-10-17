module DataSourceAdapters
  def self.adapters
    @adapters ||= {}
  end

  def self.deprecated_adapter_names
    @deprecated_adapter_names ||= Set.new
  end

  def self.register_adapter(adapter, name)
    adapters[name] = adapter
  end

  def self.deprecate_adapter(name)
    deprecated_adapter_names << name
  end

  def self.adapter_names
    adapters.keys
  end

  def self.standard_adapter_names
    adapters.select { |_, adapter| adapter < StandardAdapter }.keys
  end

  def self.deprecated?(name)
    name.in?(deprecated_adapter_names)
  end
end
