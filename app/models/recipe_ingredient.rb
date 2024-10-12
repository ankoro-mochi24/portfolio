class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient, optional: true

  validates :recipe_id, uniqueness: { scope: :ingredient_id, message: "この材料は既にレシピに追加されています" }

  attr_accessor :ingredient_name
end
