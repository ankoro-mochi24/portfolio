class RemoveUnusedIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :user_actions, :user_id, if_exists: true
    remove_index :user_kitchen_tools, :user_id, if_exists: true
    remove_index :recipe_ingredients, :recipe_id, if_exists: true
  end
end
