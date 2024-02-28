FactoryBot.define do
  factory :table_memo_log do
    table_memo
    sequence(:revision) { |n| n }
    user
    description { "# table memo" }
    description_diff { "+# table memo" }
  end
end
