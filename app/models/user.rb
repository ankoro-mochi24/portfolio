=begin
t.string "email", default: "", null: false
t.string "encrypted_password", default: "", null: false
t.string "reset_password_token"
t.datetime "reset_password_sent_at"
t.datetime "remember_created_at"
t.string "name", default: "", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.string "line_notify_token"
t.boolean "notify_enabled", default: false
t.index ["email"], name: "index_users_on_email", unique: true
t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

user(1)-(n)user_kitchen_tool(n)-(1)kitchen_tool
user(1)-(n)recipe
user(1)-(n)foodstuff
user(1)-(n)topping(n)-(1)recipe

user(1)-(n)comment(n)-(1)recipe
user(1)-(n)comment(n)-(1)foodstuff

user(1)-(n)user_action(n)-(1)recipe
user(1)-(n)user_action(n)-(1)foodstuff
user(1)-(n)user_action(n)-(1)topping
=end
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  
  # メールアドレスのフォーマットチェック
  validates :email, presence: true, uniqueness: true,
    format: { 
      with: /\A[^@\s]+@([a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}\z/, 
      message: I18n.t('activerecord.errors.models.user.attributes.email.invalid') 
    }

  # パスワードの複雑性チェック
  validates :password, length: { minimum: 6 }, 
    format: { 
      with: /\A(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}\z/, 
      message: I18n.t('activerecord.errors.models.user.attributes.password.weak') 
    }

  # アソシエーション
  has_many :foodstuffs, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :toppings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_actions, dependent: :destroy, class_name: 'UserAction', foreign_key: 'user_id'
  has_many :user_kitchen_tools, dependent: :destroy
  has_many :kitchen_tools, through: :user_kitchen_tools

  accepts_nested_attributes_for :user_kitchen_tools, allow_destroy: true
end
