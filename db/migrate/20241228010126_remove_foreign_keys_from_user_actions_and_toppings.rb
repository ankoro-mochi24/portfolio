class RemoveForeignKeysFromUserActionsAndToppings < ActiveRecord::Migration[7.0]
  def change
    # 外部キーの削除
    if foreign_key_exists?(:user_actions, :users)
      remove_foreign_key :user_actions, :users
    end

    if foreign_key_exists?(:toppings, :users)
      remove_foreign_key :toppings, :users
    end
  end
end
