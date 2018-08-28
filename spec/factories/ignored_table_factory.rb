FactoryBot.define do
  factory :ignored_table do
    data_source
    pattern ".+_(?:old|wk|l)"
  end
end
