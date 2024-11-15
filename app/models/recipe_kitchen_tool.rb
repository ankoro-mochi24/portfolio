# t.bigint "recipe_id", null: false
# t.bigint "kitchen_tool_id", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.index ["kitchen_tool_id"], name: "index_recipe_kitchen_tools_on_kitchen_tool_id"
# t.index ["recipe_id", "kitchen_tool_id"], name: "index_recipe_kitchen_tools_on_recipe_id_and_kitchen_tool_id", unique: true
# t.index ["recipe_id"], name: "index_recipe_kitchen_tools_on_recipe_id"
#
# recipe(1)-(n)recipe_kitchen_tool(n)-(1)kitchen_tool
class RecipeKitchenTool < ApplicationRecord
  belongs_to :recipe
  belongs_to :kitchen_tool

  attr_accessor :kitchen_tool_name

  validates :kitchen_tool_name, presence: true
  validates :recipe_id, uniqueness: { scope: :kitchen_tool_id }
end
