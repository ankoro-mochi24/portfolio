class DropFoodstuffImagesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :foodstuff_images
  end
end
