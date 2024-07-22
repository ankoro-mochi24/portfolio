class RecipeStep < ApplicationRecord
  mount_uploader :step_image, StepImageUploader

  belongs_to :recipe
  validates :text, presence: true

  attr_accessor :remove_step_image
  before_save :check_remove_step_image

  private

  def check_remove_step_image
    self.step_image = nil if remove_step_image == 'true'
  end
end
