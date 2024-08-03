class UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true

  validates :action_type, presence: true, inclusion: { in: %w[bookmark good bat] }
  validates :user_id, uniqueness: { scope: [:actionable_type, :actionable_id, :action_type], message: "You can only perform this action once per item." }
end
