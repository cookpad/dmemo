Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :database_memos, only: %w(index show create update destroy) do
    resources :table_memos, only: %w(index show update destroy), shallow: true
  end
end
