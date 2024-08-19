class HomeController < ApplicationController
  before_action :set_layout, only: [:top]
  before_action :set_view, only: [:top]
  before_action :show_tabs, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.search(query)
      @foodstuffs = Foodstuff.search(query)
    else
      @recipes = Recipe.all
      @foodstuffs = Foodstuff.all
    end

    case @view
    when 'recipes'
      @foodstuffs = nil
    when 'foodstuffs'
      @recipes = nil
    end
  end

  private

  def set_layout
    @use_split_layout = true
  end

  def set_view
    @view = params[:view] || 'both'
  end

  def show_tabs
    @show_tabs = true
  end
end
