FactoryBot.define do
  factory :data_source do
    name { "dmemo" }
    description { "# dmemo test db\nDB for test." }
    adapter { ActiveRecord::Base.establish_connection.db_config.configuration_hash[:adapter] }
    host { "localhost" }
    port { 5432 }
    dbname { ActiveRecord::Base.establish_connection.db_config.configuration_hash[:database] }
    user { ActiveRecord::Base.establish_connection.db_config.configuration_hash[:username] }
    password { ActiveRecord::Base.establish_connection.db_config.configuration_hash[:password] }
    encoding { nil }
    pool { 1 }

    trait :bigquery_adapter do
      adapter { "bigquery" }
      after(:create) do |data_source|
        FactoryBot.create(:bigquery_config, data_source: data_source)
      end
    end
  end
end
