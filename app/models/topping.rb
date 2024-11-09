=begin
t.bigint "recipe_id", null: false
t.bigint "user_id", null: false
t.text "name", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.index ["recipe_id", "name"], name: "index_toppings_on_recipe_id_and_name", unique: true
t.index ["recipe_id"], name: "index_toppings_on_recipe_id"
t.index ["user_id"], name: "index_toppings_on_user_id"
=end
class Topping < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  has_many :user_actions, class_name: 'UserAction', as: :actionable, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { scope: :recipe_id, message: I18n.t('activerecord.errors.models.topping.attributes.name.taken') }
end
