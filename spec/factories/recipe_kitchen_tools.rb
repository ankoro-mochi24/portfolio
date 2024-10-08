FactoryBot.define do
  factory :recipe_kitchen_tool do
    kitchen_tool_name { "フライパン" }
    recipe
    kitchen_tool
  end
end
