class AddImageToFoodstuff < ActiveRecord::Migration[7.0]
  def change
    add_column :foodstuffs, :image, :string, null: false
  end
end
