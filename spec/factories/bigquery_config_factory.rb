FactoryBot.define do
  factory :bigquery_config do
    project_id { 'sample-12345' }
    dataset { 'public' }
  end
end
