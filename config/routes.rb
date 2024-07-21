Rails.application.routes.draw do
  resources :recipes
  resources :foodstuffs
  devise_for :users
  root to: 'home#top'
  get 'cookrice'  => 'home#cookrice'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
