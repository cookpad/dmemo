FactoryBot.define do
  factory :database_memo do
    sequence(:name) {|n| "database#{n}" }
    description { "# database memo" }
  end
end
