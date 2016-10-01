FactoryGirl.define do
  factory :schema_memo do
    database_memo
    sequence(:name) {|n| "schema#{n}" }
    description "# schema memo"
  end
end
