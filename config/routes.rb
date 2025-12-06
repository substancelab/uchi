Uchi::Engine.routes.draw do
  namespace :actions do
    resources :executions, only: [:create]
  end
end
