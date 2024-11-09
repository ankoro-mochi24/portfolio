=begin
t.bigint "recipe_id", null: false
t.bigint "ingredient_id", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
t.index ["recipe_id", "ingredient_id"], name: "index_recipe_ingredients_on_recipe_id_and_ingredient_id", unique: true
=end
class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :recipe_id, uniqueness: { scope: :ingredient_id }

  attr_accessor :ingredient_name
end
