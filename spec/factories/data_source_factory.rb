FactoryBot.define do
  factory :data_source do
    name { "dmemo" }
    description { "# dmemo test db\nDB for test." }
    adapter { ActiveRecord::Base.establish_connection.spec.config[:adapter] }
    host { "localhost" }
    port { 5432 }
    dbname { ActiveRecord::Base.establish_connection.spec.config[:database] }
    user { ActiveRecord::Base.establish_connection.spec.config[:username] }
    password { ActiveRecord::Base.establish_connection.spec.config[:password] }
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
