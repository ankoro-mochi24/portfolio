class RecipeKitchenTool < ApplicationRecord
  belongs_to :recipe
  belongs_to :kitchen_tool

  attr_accessor :kitchen_tool_name

  validates :kitchen_tool_name, presence: true
  validates :recipe_id, uniqueness: { scope: :kitchen_tool_id, message: "この調理器具は既にレシピに追加されています" }
end
