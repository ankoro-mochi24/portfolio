FactoryBot.define do
  factory :recipe_step do
    recipe
    text { "このレシピのステップです。" }
    step_image { nil }  # 画像はオプション
  end
end
