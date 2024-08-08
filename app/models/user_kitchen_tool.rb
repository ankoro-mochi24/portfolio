class UserKitchenTool < ApplicationRecord
  belongs_to :user
  belongs_to :kitchen_tool

  validates :user_id, uniqueness: { scope: :kitchen_tool_id }
end
