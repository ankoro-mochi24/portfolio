class AddUniqueIndexToKitchenToolsName < ActiveRecord::Migration[7.0]
  def change
    add_index :kitchen_tools, :name, unique: true
  end
end
