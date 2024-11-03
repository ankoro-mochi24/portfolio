=begin
t.string "title", null: false
t.string "dish_image", null: false
t.bigint "user_id", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.index ["user_id"], name: "index_recipes_on_user_id"
=end
class Recipe < ApplicationRecord
  searchkick
  mount_uploader :dish_image, DishImageUploader
  
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_steps, dependent: :destroy
  has_many :recipe_kitchen_tools, dependent: :destroy
  has_many :kitchen_tools, through: :recipe_kitchen_tools
  has_many :toppings, dependent: :destroy
  
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :user_actions, class_name: 'UserAction', as: :actionable, dependent: :destroy
  
  # レシピの調理工程をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true
  
  # レシピの材料をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true
  
  # レシピの調理器具をネストされた属性として受け入れる
  accepts_nested_attributes_for :recipe_kitchen_tools, allow_destroy: true

  validates :title, presence: true
  validates :dish_image, presence: true

  # レシピには調理器具が1つ以上必要
  validate :must_have_at_least_one_kitchen_tool

  # Recipe.newの際、必ず材料に白米を加える
  after_initialize :initialize_with_rice, if: :new_record?

  private

  def initialize_with_rice
    # 「白米」という材料をデータベースから探し、なければ作成
    rice = Ingredient.find_or_create_by(name: '白米')
  
    # 「白米」をレシピの材料として追加
    self.recipe_ingredients.build(ingredient_id: rice.id, ingredient_name: rice.name)
  end
  
  def must_have_at_least_one_kitchen_tool
    if recipe_kitchen_tools.reject { |rkt| rkt.marked_for_destruction? || rkt.kitchen_tool_name.blank? }.empty?
      errors.add(:recipe_kitchen_tools, I18n.t('activerecord.errors.models.recipe.attributes.recipe_kitchen_tools.must_have_one'))
    end
  end

  # searchkickの検索インデックスに登録するデータを指定
  def search_data
    {
      title: title
    }
  end
end
