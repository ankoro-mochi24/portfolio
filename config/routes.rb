Rails.application.routes.draw do
  devise_for :users
  root to: 'home#top'
  get 'cookrice'  => 'home#cookrice'

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  concern :actionable do
    resources :user_actions, only: [:create, :destroy]
  end

  resources :recipes, except: :index, concerns: [:commentable, :actionable]  do
    collection do
      get '', to: 'recipes#index', constraints: ->(req) { req.format == :json }
    end
  end

  resources :foodstuffs, except: :index, concerns: [:commentable, :actionable] do
    collection do
      get '', to: 'foodstuffs#index', constraints: ->(req) { req.format == :json }
    end
  end
end
