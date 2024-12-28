class ChangeUserIdToUuidInFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    change_column :foodstuffs, :user_id, :uuid, using: 'user_id::text::uuid'
  end
end
