=begin
t.string "name", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
=end
class KitchenTool < ApplicationRecord
  has_many :recipe_kitchen_tools, dependent: :destroy
  has_many :recipes, through: :recipe_kitchen_tools

  has_many :user_kitchen_tools
  has_many :users, through: :user_kitchen_tools

  validates :name, presence: true
end
