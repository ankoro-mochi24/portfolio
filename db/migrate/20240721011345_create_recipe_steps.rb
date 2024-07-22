class CreateRecipeSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_steps do |t|
      t.references :recipe, null: false, foreign_key: true
      t.text :text, null: false
      t.string :step_image

      t.timestamps
    end
  end
end
