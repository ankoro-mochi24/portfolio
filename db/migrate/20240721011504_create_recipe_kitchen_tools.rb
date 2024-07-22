class CreateRecipeKitchenTools < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_kitchen_tools do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :kitchen_tool, null: false, foreign_key: true

      t.timestamps
    end
  end
end
