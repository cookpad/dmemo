# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

def ridgepole_exec(args)
  env = ENV["RAILS_ENV"] || "development"
  cd "db"
  sh "bundle", "exec", "ridgepole", "-c", "config.yml", "-E", env, *args
end

namespace :ridgepole do

  desc "Export current schema"
  task :export do
    ridgepole_exec(%w(--export Schemafile --split))
  end

  desc "Apply Schemafile"
  task :apply do
    ridgepole_exec(%w(--file Schemafile -a))
  end

  desc "Apply Schemafile (dry-run)"
  task :"dry-run" do
    ridgepole_exec(%w(--file Schemafile -a --dry-run))
  end
end
