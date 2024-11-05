=begin
t.string "name", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false

user(1)-(n)user_kitchen_tool(n)-(1)kitchen_tool
=end
class KitchenTool < ApplicationRecord
  has_many :recipe_kitchen_tools, dependent: :destroy
  has_many :recipes, through: :recipe_kitchen_tools

  has_many :user_kitchen_tools
  has_many :users, through: :user_kitchen_tools

  validates :name, presence: true
end
