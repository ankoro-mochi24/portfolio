class HomeController < ApplicationController
  before_action :set_layout, only: [:top]

  def top
    @foodstuffs = Foodstuff.all
    @recipes = Recipe.all
  end

  def cookrice
  end

  private

  def set_layout
    @use_split_layout = true
  end
end
