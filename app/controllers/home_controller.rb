class HomeController < ApplicationController
  before_action :set_view, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.includes(:user_actions).search(query, page: params[:page], per_page: 10)
      @foodstuffs = Foodstuff.includes(:user_actions).search(query, page: params[:page], per_page: 10)
    else
      @recipes = Recipe.includes(:user_actions).page(params[:page]).per(10)
      @foodstuffs = Foodstuff.includes(:user_actions).page(params[:page]).per(10)
    end

    filter_content if user_signed_in? && params[:filter].present?
    set_filter_counts if user_signed_in?

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
    when 'kitchen_tools'
      @recipes = @recipes.joins(:kitchen_tools).where(kitchen_tools: { id: current_user.kitchen_tools.pluck(:id) })
      @foodstuffs = nil
    end
  end
end
