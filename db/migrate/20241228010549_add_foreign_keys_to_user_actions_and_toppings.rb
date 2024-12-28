class AddForeignKeysToUserActionsAndToppings < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :user_actions, :users, column: :user_id
    add_foreign_key :toppings, :users, column: :user_id
  end
end
