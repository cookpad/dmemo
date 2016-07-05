ActiveSupport.on_load(:active_record) do
  ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.reject! { true }
end
