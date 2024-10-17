class UserKitchenTool < ApplicationRecord
  belongs_to :user
  belongs_to :kitchen_tool, optional: true

  attr_accessor :kitchen_tool_name

  validates :user_id, uniqueness: { scope: :kitchen_tool_id }
  validates :kitchen_tool_name, presence: true

  before_validation :set_kitchen_tool

  private

  def set_kitchen_tool
    if kitchen_tool_name.present?
      self.kitchen_tool = KitchenTool.find_or_create_by(name: kitchen_tool_name)
    end
  end
end
