class Recipe < ApplicationRecord
  mount_uploader :dish_image, DishImageUploader
  
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_steps, dependent: :destroy
  has_many :recipe_kitchen_tools, dependent: :destroy
  has_many :kitchen_tools, through: :recipe_kitchen_tools
  has_many :toppings, dependent: :destroy
  
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :user_actions, as: :actionable, dependent: :destroy, class_name: 'UserAction'
  
  # レシピの調理工程をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true
  
  # レシピの材料をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true
  
  # レシピの調理器具をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_kitchen_tools, allow_destroy: true

  validates :title, presence: true
  validate :must_have_at_least_one_kitchen_tool

  attr_accessor :remove_dish_image
  before_save :check_remove_dish_image
  after_initialize :ensure_rice_present

  private

  def check_remove_dish_image
    self.dish_image = nil if remove_dish_image == 'true'
  end

  def ensure_rice_present
    if self.new_record? && self.recipe_ingredients.none? { |ri| ri.ingredient_name == '白米' }
      self.recipe_ingredients.build(ingredient_name: '白米')
    end
  end

  def must_have_at_least_one_kitchen_tool
    if recipe_kitchen_tools.reject { |rkt| rkt.marked_for_destruction? || rkt.kitchen_tool_name.blank? }.empty?
      errors.add(:recipe_kitchen_tools, 'を最低1つ追加してください')
    end
  end
end
