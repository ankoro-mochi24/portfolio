class ChangeUserIdToUuidInComments < ActiveRecord::Migration[7.0]
  def change
    change_column :comments, :user_id, :uuid, using: 'user_id::text::uuid'
  end
end
