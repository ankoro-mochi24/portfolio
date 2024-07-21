class RecipeStep < ApplicationRecord
  mount_uploader :step_image, StepImageUploader
  
  belongs_to :recipe

  validates :text, presence: true
end
