FactoryBot.define do
  factory :recipe do
    title { "テストレシピ" }
    dish_image { File.open(Rails.root.join('spec/fixtures/sample.jpg')) }
    user

    after(:build) do |recipe|
      recipe.recipe_kitchen_tools << FactoryBot.build(:recipe_kitchen_tool, recipe: recipe)
      recipe.recipe_ingredients << FactoryBot.build(:recipe_ingredient, recipe: recipe)
    end
  end
end
