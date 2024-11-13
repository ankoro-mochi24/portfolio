FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    email { Faker::Internet.unique.email }
    password { "password1" }
    line_notify_token { nil }

    # user_with_recipes
    factory :user_with_recipes do
      transient do
        # 作成するレシピの数を指定できる
        recipes_count { 5 }
      end

      # ユーザーが作成された後に、指定された数のレシピを関連付ける
      after(:create) do |user, evaluator|
        create_list(:recipe, evaluator.recipes_count, user: user)
      end
    end

    # user_with_foodstuffs
    factory :user_with_foodstuffs do
      transient do
        # 作成する食材の数を指定できる
        foodstuffs_count { 5 }
      end

      # ユーザーが作成された後に、指定された数の食材を関連付ける
      after(:create) do |user, evaluator|
        create_list(:foodstuff, evaluator.foodstuffs_count, user: user)
      end
    end

    # user_with_comments
    factory :user_with_comments do
      transient do
        # 作成するコメントの数を指定できる
        comments_count { 5 }
      end

      # ユーザーが作成された後に、指定された数のコメントを関連付ける
      after(:create) do |user, evaluator|
        create_list(:comment, evaluator.comments_count, user: user)
      end
    end

    # user_with_actions
    factory :user_with_actions do
      transient do
        # 作成するアクションの数を指定できる
        actions_count { 5 }
      end

      # ユーザーが作成された後に、指定された数のアクションを関連付ける
      after(:create) do |user, evaluator|
        create_list(:user_action, evaluator.actions_count, user: user)
      end
    end
  end
end
