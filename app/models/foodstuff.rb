class Foodstuff < ApplicationRecord
  belongs_to :user
  has_many :foodstuff_image, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true}
  validates :link, presence: true
end
