class AddUniqueIndexToRecipeKitchenTools < ActiveRecord::Migration[7.0]
  def change
    add_index :recipe_kitchen_tools, [:recipe_id, :kitchen_tool_id], unique: true
  end
end
