# t.bigint "user_id", null: false
# t.bigint "kitchen_tool_id", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.index ["kitchen_tool_id"], name: "index_user_kitchen_tools_on_kitchen_tool_id"
# t.index ["user_id", "kitchen_tool_id"], name: "index_user_kitchen_tools_on_user_id_and_kitchen_tool_id", unique: true
#
# user(1)-(n)user_kitchen_tool(n)-(1)kitchen_tool
class UserKitchenTool < ApplicationRecord
  belongs_to :user
  belongs_to :kitchen_tool, optional: true

  attr_accessor :kitchen_tool_name

  validates :user_id, uniqueness: { scope: :kitchen_tool_id }

  before_validation :set_kitchen_tool

  private

  def set_kitchen_tool
    Rails.logger.debug "Before Validation: kitchen_tool_name=#{kitchen_tool_name.inspect}"
    Rails.logger.debug "Before Validation: kitchen_tool=#{kitchen_tool.inspect}"

    if kitchen_tool_name.present?
      self.kitchen_tool = KitchenTool.find_or_create_by(name: kitchen_tool_name)
    else
      self.kitchen_tool = nil
    end
  end
end
