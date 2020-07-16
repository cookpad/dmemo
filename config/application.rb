require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dmemo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 5.2
    config.active_record.belongs_to_required_by_default = false

    config.eager_load_paths << "#{Rails.root}/lib/autoload"
    config.allow_anonymous_to_read = ENV.has_key? 'ALLOW_ANONYMOUS_TO_READ'
  end
end
