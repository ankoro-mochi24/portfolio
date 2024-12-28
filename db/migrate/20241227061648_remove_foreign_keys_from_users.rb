class RemoveForeignKeysFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :comments, :users
    remove_foreign_key :foodstuffs, :users
    remove_foreign_key :recipes, :users
    remove_foreign_key :toppings, :users
    remove_foreign_key :user_actions, :users
    remove_foreign_key :user_kitchen_tools, :users
  end
end
