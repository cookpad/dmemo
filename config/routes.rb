Rails.application.routes.draw do
  root "top#show"

  resources :database_memos, only: %w(index show create) do
    resources :table_memos, only: %w(index show)
  end
end
