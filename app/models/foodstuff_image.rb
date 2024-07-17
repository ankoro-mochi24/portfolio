class FoodstuffImage < ApplicationRecord
  belongs_to :foodstuff

  validates :image, presence: true
end
