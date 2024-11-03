=begin
t.bigint "user_id", null: false
t.string "action_type", null: false
t.string "actionable_type", null: false
t.bigint "actionable_id", null: false
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.index ["user_id", "actionable_type", "actionable_id", "action_type"], name: "index_user_actions_on_user_and_actionable_and_action_type", unique: true

User(1)-(n)UserAction(n)-(1)Foodstuff
User(1)-(n)UserAction(n)-(1)Recipe
User(1)-(n)UserAction(n)-(1)Topping

action_type: bookmark/good/bad
actionable_type: recipe/foodstuff/topping
actionable_id: recipe.id/foodstuff.id/topping.id
=end
class UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true

  validates :action_type, presence: true, inclusion: { in: %w[bookmark good bad] }

  validates :user_id, uniqueness: {
    scope: [:actionable_type, :actionable_id, :action_type],
    message: I18n.t('activerecord.errors.models.user_action.attributes.user_id.taken')
  }

  validate :good_or_bad

  private

  def good_or_bad
    if action_type == 'good' && user.user_actions.exists?(actionable: actionable, action_type: 'bad')
      errors.add(:base, I18n.t('activerecord.errors.models.user_action.messages.good_bad_conflict'))
    elsif action_type == 'bad' && user.user_actions.exists?(actionable: actionable, action_type: 'good')
      errors.add(:base, I18n.t('activerecord.errors.models.user_action.messages.good_bad_conflict'))
    end
  end
end
