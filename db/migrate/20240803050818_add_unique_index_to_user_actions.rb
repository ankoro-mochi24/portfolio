class AddUniqueIndexToUserActions < ActiveRecord::Migration[6.1]
  def change
    add_index :user_actions, [:user_id, :actionable_type, :actionable_id, :action_type], unique: true, name: 'index_user_actions_on_user_and_actionable_and_action_type'
  end
end
