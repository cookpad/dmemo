def ridgepole_exec(args)
  args = args.dup
  env = ENV["RAILS_ENV"] || "development"
  drop_table = ENV.fetch("RIDGEPOLE_DROP_TABLE", nil)
  if drop_table
    args << "--drop-table"
  end
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
