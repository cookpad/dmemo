FactoryBot.define do
  factory :keyword_log do
    keyword
    sequence(:revision) {|n| n }
    user
    description "# keyword memo"
    description_diff "+# keyrword memo"
  end
end
