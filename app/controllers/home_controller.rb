class HomeController < ApplicationController
  before_action :set_view, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.search(query)
      @foodstuffs = Foodstuff.search(query)
    else
      @recipes = Recipe.all
      @foodstuffs = Foodstuff.all
    end
  
    filter_content if user_signed_in? && params[:filter].present?

    @recipes = @recipes.page(params[:page]).per(10) if @recipes.present?
    @foodstuffs = @foodstuffs.page(params[:page]).per(10) if @foodstuffs.present?

    case @view
    when 'recipes'
      @foodstuffs = nil
    when 'foodstuffs'
      @recipes = nil
    end
  end

  private

  def set_view
    @view = params[:view] || 'both'
  end

  def filter_content
    case params[:filter]
    when 'bookmarks'
      @recipes = @recipes.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Recipe' })
      @foodstuffs = @foodstuffs.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Foodstuff' })
    when 'good'
      @recipes = @recipes.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Recipe' })
      @foodstuffs = @foodstuffs.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Foodstuff' })
    when 'bad'
      @recipes = @recipes.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Recipe' })
      @foodstuffs = @foodstuffs.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Foodstuff' })
    end
  end
end
