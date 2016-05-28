Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :databases, controller: :database_memos, as: :database_memos, only: %w(index show edit update destroy) do
    resources :tables, controller: :table_memos, as: :table_memos, only: %w(show edit update destroy), shallow: true do
      resources :columns, controller: :column_memos, as: :column_memos, only: %w(update destroy)
    end
  end

  get "/databases/:database_name/:name" => "table_memos#show", as: "database_memo_table"

  resource :markdown_preview, only: %w(create)

  get "auth/google_oauth2/callback", to: "sessions#create"
  get "logout", to: "sessions#destroy"
end
