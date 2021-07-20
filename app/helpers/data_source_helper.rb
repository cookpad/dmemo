module DataSourceHelper
  def subscribe?(schema_name)
    @subscribe_schema_names.include?(schema_name)
  end

  def exist?(schema_name)
    @redshift_schema_names.include?(schema_name)
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
