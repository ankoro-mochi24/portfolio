class CreateFoodstuffImages < ActiveRecord::Migration[7.0]
  def change
    create_table :foodstuff_images do |t|
      t.references :foodstuffs, null: false, foreign_key: true
      t.string :image, null: false
      
      t.timestamps
    end
  end
end
