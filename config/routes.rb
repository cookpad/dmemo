Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :database_memos, param: :name, only: %w(index show create) do
    resources :table_memos, param: :name, only: %w(index show)
  end
end
