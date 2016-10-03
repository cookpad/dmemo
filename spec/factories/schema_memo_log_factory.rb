FactoryGirl.define do
  factory :schema_memo_log do
    schema_memo
    sequence(:revision) {|n| n }
    user
    description "# schema memo"
    description_diff "+# schema memo"
  end
end
