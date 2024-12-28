class AddForeignKeyToCommentsFoodstuffsRecipesUserKitchenTools < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :comments, :users, column: :user_id
    add_foreign_key :foodstuffs, :users, column: :user_id
    add_foreign_key :recipes, :users, column: :user_id
    add_foreign_key :user_kitchen_tools, :users, column: :user_id
  end
end
