# t.string "name", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true
end
