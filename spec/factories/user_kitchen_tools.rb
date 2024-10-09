# spec/factories/user_kitchen_tools.rb
FactoryBot.define do
  factory :user_kitchen_tool do
    association :user
    association :kitchen_tool
  end
end
