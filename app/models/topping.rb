class Topping < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :name, presence: true
end
