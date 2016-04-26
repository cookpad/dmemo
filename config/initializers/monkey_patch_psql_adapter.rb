ActiveSupport.on_load(:active_record) do
  require "dmemo/tables_includes_views"
end
