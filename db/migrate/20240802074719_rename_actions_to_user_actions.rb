class RenameActionsToUserActions < ActiveRecord::Migration[6.1]
  def change
    rename_table :actions, :user_actions
  end
end
