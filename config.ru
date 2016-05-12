# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

use Rack::RubyProf, path: Rails.root.join('tmp', 'profile') if ENV["RUBY_PROF_ON"]

run Rails.application
