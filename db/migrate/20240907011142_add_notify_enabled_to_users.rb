class AddNotifyEnabledToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notify_enabled, :boolean, default: false
  end
end
