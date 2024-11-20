FactoryBot.define do
  factory :user_action do
    action_type { "good" }
    user
    actionable factory: %i[recipe] # recipeなどの関連付け
  end
end
