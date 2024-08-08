class CreateUserKitchenTools < ActiveRecord::Migration[7.0]
  def change
    create_table :user_kitchen_tools do |t|
      t.references :user, null: false, foreign_key: true
      t.references :kitchen_tool, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_kitchen_tools, [:user_id, :kitchen_tool_id], unique: true
  end
end
