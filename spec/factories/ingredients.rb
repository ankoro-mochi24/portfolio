FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "材料_#{n}" }
  end
end
