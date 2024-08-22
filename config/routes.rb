Rails.application.routes.draw do
  devise_for :users
  root to: 'home#top'

  get 'recipes', to: 'home#top', defaults: { view: 'recipes' }, as: 'recipes_view'
  get 'foodstuffs', to: 'home#top', defaults: { view: 'foodstuffs' }, as: 'foodstuffs_view'

  get 'cookrice' => 'home#cookrice'

  resources :users, only: [:show, :edit, :update] do
    member do
      get 'bookmarked_recipes', to: 'users#bookmarked_recipes'
      get 'bookmarked_foodstuffs', to: 'users#bookmarked_foodstuffs'
      get 'good_recipes', to: 'users#good_recipes'
      get 'bad_recipes', to: 'users#bad_recipes'
      get 'good_foodstuffs', to: 'users#good_foodstuffs'
      get 'bad_foodstuffs', to: 'users#bad_foodstuffs'
    end
  end

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  concern :actionable do
    resources :user_actions, only: [:create, :destroy]
  end

  resources :recipes, except: :index, concerns: [:commentable, :actionable] do
    member do
      post 'add_topping'
      delete 'remove_topping'
    end
    collection do
      get '', to: 'recipes#index', constraints: ->(req) { req.format == :json }
    end
  end

  resources :foodstuffs, except: :index, concerns: [:commentable, :actionable] do
    collection do
      get '', to: 'foodstuffs#index', constraints: ->(req) { req.format == :json }
    end
  end

  resources :toppings, only: [] do
    concerns :actionable
  end
end
