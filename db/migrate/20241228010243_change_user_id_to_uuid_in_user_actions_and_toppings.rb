class ChangeUserIdToUuidInUserActionsAndToppings < ActiveRecord::Migration[7.0]
  def change
    # user_actions テーブル
    if column_exists?(:user_actions, :user_id)
      change_column :user_actions, :user_id, :uuid, using: 'user_id::text::uuid'
    end

    # toppings テーブル
    if column_exists?(:toppings, :user_id)
      change_column :toppings, :user_id, :uuid, using: 'user_id::text::uuid'
    end
  end
end
