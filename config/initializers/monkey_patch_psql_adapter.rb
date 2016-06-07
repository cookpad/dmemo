ActiveSupport.on_load(:active_record) do
  require "monkey_patch/tables_includes_views"
end
