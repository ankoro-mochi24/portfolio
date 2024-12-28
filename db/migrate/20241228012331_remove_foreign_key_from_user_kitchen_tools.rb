class RemoveForeignKeyFromUserKitchenTools < ActiveRecord::Migration[7.0]
  def change
    if foreign_key_exists?(:user_kitchen_tools, :users)
      remove_foreign_key :user_kitchen_tools, :users
    end
  end
end
