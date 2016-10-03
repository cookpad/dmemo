FactoryGirl.define do
  factory :database_memo_log do
    database_memo
    sequence(:revision) {|n| n }
    user
    description "# database memo"
    description_diff "+# database memo"
  end
end
