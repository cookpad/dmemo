Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :databases, controller: :database_memos, as: :database_memos, only: %w(index show create update destroy) do
    get "/:name" => "table_memos#show", as: "table"

    resources :tables, controller: :table_memos, as: :table_memos, only: %w(index show update destroy), shallow: true do
      resources :columns, controller: :column_memos, as: :column_memos, only: %w(update destroy)
    end
  end

  get "auth/google_oauth2/callback", to: "sessions#create"
  get "logout", to: "sessions#destroy"
end
