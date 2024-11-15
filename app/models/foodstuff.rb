# t.string "name", null: false
# t.decimal "price", precision: 10, null: false
# t.text "description"
# t.string "link", null: false
# t.bigint "user_id", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.string "image", null: false
# t.index ["user_id"], name: "index_foodstuffs_on_user_id"

class Foodstuff < ApplicationRecord
  # 検索機能の設定
  searchkick 

  # 画像アップロードの設定
  mount_uploaders :image, FoodstuffImageUploader 
  serialize :image, JSON

  # アソシエーションの設定
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :user_actions, class_name: 'UserAction', as: :actionable, dependent: :destroy

  # バリデーションの設定
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :link, presence: true
  validates :image, presence: true
end
