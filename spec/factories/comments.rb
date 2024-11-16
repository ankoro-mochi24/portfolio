FactoryBot.define do
  factory :comment do
    body { "テストコメント" }
    user
    commentable factory: %i[recipe] # Recipeをcommentableに指定
  end
end
