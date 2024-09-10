Rails.application.routes.draw do
  root to: 'home#top'

  devise_for :users, skip: :registrations, controllers: {
    registrations: 'devise/registrations'
  }
  
  as :user do
    get 'users/sign_up' => 'devise/registrations#new', as: :new_user_registration
    post 'users' => 'devise/registrations#create', as: :user_registration
    delete 'users' => 'devise/registrations#destroy'
    # editを除外するため、ここでは追加しません
  end

  get 'line_notify/authorize', to: 'line_notify#authorize'
  get 'line_notify/callback', to: 'line_notify#callback'

  get 'recipes', to: 'home#top', defaults: { view: 'recipes' }, as: 'recipes_view'
  get 'foodstuffs', to: 'home#top', defaults: { view: 'foodstuffs' }, as: 'foodstuffs_view'

  get 'cookrice' => 'home#cookrice'

  # カレントユーザー用のルート
  resource :profile, only: [:show, :edit, :update, :destroy] do
    get 'posts', to: 'profiles#posts', as: 'posts'
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
