FactoryGirl.define do
  factory :data_source do
    name "dmemo"
    description "# dmemo test db\nDB for test."
    adapter "postgresql"
    host "localhost"
    port 5432
    dbname "dmemo_test"
    user "dmemo"
    password ""
  end
end
