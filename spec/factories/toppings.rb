FactoryBot.define do
  factory :topping do
    name { "Test Topping" }
    user
    recipe
  end
end
