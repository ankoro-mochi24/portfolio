class UserKitchenTool < ApplicationRecord
  belongs_to :user
  belongs_to :kitchen_tool

  attr_accessor :kitchen_tool_name

  validates :user_id, uniqueness: { scope: :kitchen_tool_id }
end
