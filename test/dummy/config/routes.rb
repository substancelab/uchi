Rails.application.routes.draw do
  mount Uchi::Engine => "/uchi"

  namespace :uchi do
    resources :authors
  end
end
