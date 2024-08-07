class HomeController < ApplicationController
  before_action :set_layout, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.search(query)
      @foodstuffs = Foodstuff.search(query)
    else
      @recipes = Recipe.all
      @foodstuffs = Foodstuff.all
    end
  end

  def cookrice
  end

  private

  def set_layout
    @use_split_layout = true
  end
end
