FactoryBot.define do
  factory :comment do
    body { "テストコメント" }
    user
    association :commentable, factory: :recipe # Recipeをcommentableに指定
  end
end
