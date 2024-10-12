class AddCascadeDeleteToRecipeIngredients < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :recipe_ingredients, :recipes
    add_foreign_key :recipe_ingredients, :recipes, on_delete: :cascade
  end
end
