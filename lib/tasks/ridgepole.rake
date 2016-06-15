def ridgepole_exec(args)
  env = ENV["RAILS_ENV"] || "development"
  cd "db"
  sh "bundle", "exec", "ridgepole", "-c", "../config/database.yml", "-E", env, *args
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
