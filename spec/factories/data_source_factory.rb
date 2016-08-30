FactoryGirl.define do
  factory :data_source do
    name "dmemo"
    description "# dmemo test db\nDB for test."
    adapter { ActiveRecord::Base.establish_connection.spec.config[:adapter] }
    host "localhost"
    port 5432
    dbname { ActiveRecord::Base.establish_connection.spec.config[:database] }
    user { ActiveRecord::Base.establish_connection.spec.config[:username] }
    password { ActiveRecord::Base.establish_connection.spec.config[:password] }
    encoding nil
    pool 1
  end
end
