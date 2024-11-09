class RemoveIndexActionsOnActionable < ActiveRecord::Migration[7.0]
  def change
    remove_index :user_actions, name: "index_actions_on_actionable"
  end
end
