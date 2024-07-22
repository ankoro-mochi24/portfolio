class KitchenTool < ApplicationRecord
  has_many :recipe_kitchen_tools
  has_many :recipes, through: :recipe_kitchen_tools

  validates :name, presence: true
end
