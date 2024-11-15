# t.bigint "user_id", null: false
# t.text "body", null: false
# t.string "commentable_type", null: false
# t.bigint "commentable_id", null: false
#
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
# t.index ["user_id"], name: "index_comments_on_user_id"
#
# Foodstuff(1)-(n)Comment
# Recipe(1)-(n)Comment
# User(1)-(n)Comment
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true, length: { minimum: 1, maximum: 400 }
end
