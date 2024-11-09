FactoryBot.define do
  factory :user_action do
    action_type { "good" }
    user
    association :actionable, factory: :recipe # recipeなどの関連付け
  end
end
