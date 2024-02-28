FactoryBot.define do
  factory :table_memo do
    schema_memo
    sequence(:name) { |n| "table#{n}" }
    description { "# table memo" }
  end
end
