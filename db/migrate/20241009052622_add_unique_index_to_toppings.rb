class AddUniqueIndexToToppings < ActiveRecord::Migration[7.0]
  def change
    add_index :toppings, [:recipe_id, :name], unique: true
  end
end
