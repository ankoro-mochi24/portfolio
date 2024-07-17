class CreateFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :foodstuffs do |t|
      t.string :name, null: false
      t.decimal :price, null: false, precision: 10, scale: 0
      t.text :description
      t.string :link, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
