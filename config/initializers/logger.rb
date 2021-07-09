Rails.application.configure do
  config.middleware.swap(
    Rails::Rack::Logger,
    Silencer::Logger,
    config.log_tags,
    silence: ["/site/sha"]
  )
end
