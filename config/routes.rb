Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :database_memos, only: %w(index show create destroy) do
    resources :table_memos, only: %w(index show)
  end
end
