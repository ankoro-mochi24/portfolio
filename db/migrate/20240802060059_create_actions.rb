class CreateActions < ActiveRecord::Migration[7.0]
  def change
    create_table :actions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type, null: false
      t.references :actionable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
