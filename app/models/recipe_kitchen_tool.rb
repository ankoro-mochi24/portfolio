class RecipeKitchenTool < ApplicationRecord
  belongs_to :recipe
  belongs_to :kitchen_tool, optional: true

  attr_accessor :kitchen_tool_name

  validates :kitchen_tool_name, presence: true
end
