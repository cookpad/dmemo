FactoryGirl.define do
  factory :column_memo_log do
    column_memo
    sequence(:revision) {|n| n }
    user
    description "# column memo"
    description_diff "+# column memo"
  end
end
