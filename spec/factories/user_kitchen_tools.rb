FactoryBot.define do
  factory :user_kitchen_tool do
    association :user
    association :kitchen_tool
    kitchen_tool_name { "フライパン" }
  end
end
