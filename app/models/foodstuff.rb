class Foodstuff < ApplicationRecord
  belongs_to :user
  mount_uploaders :image, FoodstuffImageUploader
  serialize :image, JSON

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true}
  validates :link, presence: true
  validates :image, presence: true
end
