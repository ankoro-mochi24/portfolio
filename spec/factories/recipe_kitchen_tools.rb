FactoryBot.define do
  factory :recipe_kitchen_tool do
    association :recipe
    association :kitchen_tool
    kitchen_tool_name { kitchen_tool&.name || "フライパン" }
  end
end
