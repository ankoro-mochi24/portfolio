class Action < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true

  # action_typeのバリデーション
  validates :action_type, presence: true, inclusion: { in: %w[bookmark good bat] }
end
