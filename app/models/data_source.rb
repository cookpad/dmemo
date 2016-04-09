class DataSource < ActiveRecord::Base
  def source_connection
    @source_connection ||= ActiveRecord::Base.establish_connection(
      adapter: adapter,
      host: host,
      port: port,
      username: user,
      password: password,
      database: database,
    )
  end
end
