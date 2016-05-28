Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)
  resources :users, except: %w(destroy)

  resources :databases, controller: :database_memos, as: :database_memos do
    resources :tables, controller: :table_memos, as: :table_memos, except: %w(index), shallow: true do
      resources :columns, controller: :column_memos, as: :column_memos, only: %w(update destroy)
    end
  end

  get "/databases/:database_name/:name" => "table_memos#show", as: "database_memo_table"

  resource :markdown_preview, only: %w(create)

  get "auth/google_oauth2/callback", to: "sessions#create"
  get "logout", to: "sessions#destroy"
end
