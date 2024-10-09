# spec/factories/toppings.rb
FactoryBot.define do
  factory :topping do
    name { "Test Topping" }
    association :user
    association :recipe
  end
end
