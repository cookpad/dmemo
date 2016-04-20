Rails.application.routes.draw do
  root "top#show"

  resources :data_sources, except: %w(show)

  resources :database_memos, only: %w(index show create update destroy) do
    resources :table_memos, only: %w(index show update destroy), shallow: true do
      resources :column_memos, only: %w(update destroy)
    end
  end

  get "/s/:database_name" => "database_memos#show", as: "shorten_database"
  get "/s/:database_name/:table_name" => "table_memos#show", as: "shorten_table"
end
