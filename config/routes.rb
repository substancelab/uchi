Uchi::Engine.routes.draw do
  namespace :actions do
    resources :executions, only: [:create]
  end
  namespace :belongs_to do
    resources :associated_records, only: [:index]
  end
end
