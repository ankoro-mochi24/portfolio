=begin
action_type: bookmark/good/bad
actionable_type: recipe/foodstuff
actionable_id: recipe.id/foodstuff.id
=end
class UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true

  validates :action_type, presence: true, inclusion: { in: %w[bookmark good bad] }
  validates :user_id, uniqueness: { scope: [:actionable_type, :actionable_id, :action_type], message: "You can only perform this action once per item." }
  
  validate :good_or_bad

  private

  def good_or_bad
    if action_type == 'good' && user.user_actions.exists?(actionable: actionable, action_type: 'bad')
      errors.add(:base, "Cannot have both good and bad actions at the same time")
    elsif action_type == 'bad' && user.user_actions.exists?(actionable: actionable, action_type: 'good')
      errors.add(:base, "Cannot have both good and bad actions at the same time")
    end
  end
end
