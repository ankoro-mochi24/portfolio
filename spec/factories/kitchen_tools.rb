FactoryBot.define do
  factory :kitchen_tool do
    sequence(:name) { |n| "調理器具#{n}" }
  end
end
