class Recipe < ApplicationRecord
  mount_uploader :dish_image, DishImageUploader
  
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_steps, dependent: :destroy
  has_many :recipe_kitchen_tools, dependent: :destroy
  has_many :kitchen_tools, through: :recipe_kitchen_tools

  # レシピの調理工程をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true
  
  # レシピの材料をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true
  
  # レシピの調理器具をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_kitchen_tools, allow_destroy: true

  validates :title, presence: true
end
