FactoryBot.define do
  factory :recipe do
    title { "テストレシピ" }
    dish_image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'), 'image/jpeg') }
    association :user

    after(:build) do |recipe|
      recipe.recipe_kitchen_tools << FactoryBot.build(:recipe_kitchen_tool, recipe: recipe, kitchen_tool_name: "フライパン")
    end
  end
end
