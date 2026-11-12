module DataSourceHelper
  def adapter_options_for_select(data_source)
    options = DataSourceAdapters.adapter_names.map { |name| [name, name] }
    options << ["#{data_source.adapter} (deprecated)", data_source.adapter] if data_source.deprecated_adapter?
    options
  end

  def subscribe?(schema_name)
    @subscribe_schema_names.include?(schema_name)
  end

  def exist?(schema_name)
    @data_source_schema_names.include?(schema_name)
  end

  def able_to_import?(schema_name)
    !subscribe?(schema_name) && exist?(schema_name)
  end

  def able_to_unlink?(schema_name)
    subscribe?(schema_name)
  end

  def disable_import_button(schema_name)
    able_to_import?(schema_name) ? "" : "disabled"
  end

  def disable_unlink_button(schema_name)
    able_to_unlink?(schema_name) ? "" : "disabled"
  end
end
