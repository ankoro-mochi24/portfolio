class ChangeUserIdToUuidInUserKitchenTools < ActiveRecord::Migration[7.0]
  def change
    change_column :user_kitchen_tools, :user_id, :uuid, using: 'user_id::text::uuid'
  end
end
