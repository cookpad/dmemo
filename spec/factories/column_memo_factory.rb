FactoryBot.define do
  factory :column_memo do
    table_memo
    sequence(:name) {|n| "column#{n}" }
    description "# column memo"
  end
end
