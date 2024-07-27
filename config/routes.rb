Rails.application.routes.draw do
  devise_for :users
  root to: 'home#top'
  get 'cookrice'  => 'home#cookrice'

  resources :recipes, except: :index do
    collection do
      get '', to: 'recipes#index', constraints: ->(req) { req.format == :json }
    end
  end

  resources :foodstuffs, except: :index do
    collection do
      get '', to: 'foodstuffs#index', constraints: ->(req) { req.format == :json }
    end
  end
end
