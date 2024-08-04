class UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true

  validates :action_type, presence: true, inclusion: { in: %w[bookmark good bat] }
  validates :user_id, uniqueness: { scope: [:actionable_type, :actionable_id, :action_type], message: "You can only perform this action once per item." }
  
  validate :good_or_bat

  private

  def good_or_bat
    if action_type == 'good' && user.user_actions.exists?(actionable: actionable, action_type: 'bat')
      errors.add(:base, "Cannot have both good and bat actions at the same time")
    elsif action_type == 'bat' && user.user_actions.exists?(actionable: actionable, action_type: 'good')
      errors.add(:base, "Cannot have both good and bat actions at the same time")
    end
  end
end
