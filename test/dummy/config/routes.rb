Rails.application.routes.draw do
  mount Uchi::Engine => "/uchi"

  namespace :uchi do
    resources :authors
    resources :books
    resources :titles
  end
end
