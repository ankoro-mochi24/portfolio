class Topping < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  has_many :user_actions, as: :actionable, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { scope: :recipe_id, message: "は同じレシピ内で重複しています" }
end
