FactoryBot.define do
  factory :user_kitchen_tool do
    user
    kitchen_tool
    kitchen_tool_name { "フライパン" }
  end
end
