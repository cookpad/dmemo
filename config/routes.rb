Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :databases, controller: :database_memos, as: :database_memos, only: %w(index show create update destroy) do
    resources :tables, controller: :table_memos, as: :table_memos, only: %w(index show update destroy), shallow: true do
      resources :columns, controller: :column_memos, as: :column_memos, only: %w(update destroy)
    end
  end

  get "auth/google_oauth2/callback", to: "sessions#create"
  get "logout", to: "sessions#destroy"

  get "/s/:database_name" => "database_memos#show", as: "shorten_database"
  get "/s/:database_name/:table_name" => "table_memos#show", as: "shorten_table"
end
