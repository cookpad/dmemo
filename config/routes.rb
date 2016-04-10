Rails.application.routes.draw do
  root "top#show"

  resources :database_memos, only: %w(create)
end
