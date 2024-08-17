class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :foodstuffs, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :toppings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_actions, dependent: :destroy, class_name: 'UserAction', foreign_key: 'user_id'
  has_many :user_kitchen_tools
  has_many :kitchen_tools, through: :user_kitchen_tools

  accepts_nested_attributes_for :user_kitchen_tools, allow_destroy: true
end
