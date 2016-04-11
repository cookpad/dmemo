Rails.application.routes.draw do
  root "top#show"

  resources :database_memos, only: %w(show create)

  resources :table_memos, only: %w(show)
end
