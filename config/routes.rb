Rails.application.routes.draw do
  root to: 'home#top'  # トップページのルート

  # devise/registrations#/edit以外へのルート
  devise_for :users, skip: :registrations, controllers: {
    registrations: 'devise/registrations'
  }  # deviseによるユーザー認証（registrationsは除外）
  as :user do
    get 'users/sign_up' => 'devise/registrations#new', as: :new_user_registration  # ユーザー新規登録ページ
    post 'users' => 'devise/registrations#create', as: :user_registration  # ユーザー登録
    delete 'users' => 'devise/registrations#destroy'  # ユーザー削除
    # editを除外するため、ここでは追加しません
  end

  get 'line_notify/authorize', to: 'line_notify#authorize'  # LINE Notify認証
  get 'line_notify/callback', to: 'line_notify#callback'  # LINE Notifyコールバック

  get 'recipes', to: 'home#top', defaults: { view: 'recipes' }, as: 'recipes_view'  # レシピ一覧表示
  get 'foodstuffs', to: 'home#top', defaults: { view: 'foodstuffs' }, as: 'foodstuffs_view'  # 食品一覧表示

  get 'cookrice' => 'home#cookrice'  # 炊飯チュートリアル

  # マイページ
  resource :profile, only: [:show, :edit, :update, :destroy] do
    get 'posts', to: 'profiles#posts', as: 'posts'  # 投稿したレシピ/食品
  end

  # コメントに関する共通ルート
  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]  # コメント作成、編集、更新、削除
  end
  # ユーザーアクション（いいね、ブックマークなど）
  concern :actionable do
    resources :user_actions, only: [:create, :destroy]  # アクション作成、削除
  end

  # レシピ
  resources :recipes, except: :index, concerns: [:commentable, :actionable] do
    member do # 投稿された各レシピに対してカスタムアクションを定義
      post 'add_topping'  # トッピングの追加
      delete 'remove_topping'  # トッピングの削除
    end
    collection do
      get '', to: 'recipes#index', constraints: ->(req) { req.format == :json }  # レシピ一覧（JSONフォーマットの場合）
    end
  end

  # 食品
  resources :foodstuffs, except: :index, concerns: [:commentable, :actionable] do
    collection do
      get '', to: 'foodstuffs#index', constraints: ->(req) { req.format == :json }  # 食品一覧（JSONフォーマットの場合）
    end
  end

  # トッピング
  resources :toppings, only: [] do
    concerns :actionable  # トッピングに対するアクション
  end
end
