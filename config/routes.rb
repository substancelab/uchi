Uchi::Engine.routes.draw do
  scope "_" do
    namespace :actions do
      resources :executions, only: [:create]
    end
    namespace :belongs_to do
      resources :associated_records, only: [:index]
    end
    namespace :has_many do
      resources :associated_records, only: [:index]
    end
    resources :search, only: [:index], path: "search"
    namespace :search do
      resources :results, only: [:index]
    end
  end
end
