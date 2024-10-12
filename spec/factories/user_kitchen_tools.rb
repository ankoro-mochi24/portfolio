FactoryBot.define do
  factory :user_kitchen_tool do
    association :user
    association :kitchen_tool
  end
end
