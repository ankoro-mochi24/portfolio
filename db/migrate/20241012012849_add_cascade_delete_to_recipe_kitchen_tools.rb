class AddCascadeDeleteToRecipeKitchenTools < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :recipe_kitchen_tools, :recipes
    add_foreign_key :recipe_kitchen_tools, :recipes, on_delete: :cascade
  end
end
