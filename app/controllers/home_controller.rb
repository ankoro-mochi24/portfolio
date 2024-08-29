class HomeController < ApplicationController
  before_action :set_view, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.search(query, page: params[:page], per_page: 10).includes(:user_actions)
      @foodstuffs = Foodstuff.search(query, page: params[:page], per_page: 10).includes(:user_actions)
    else
      @recipes = Recipe.page(params[:page]).per(10).includes(:user_actions)
      @foodstuffs = Foodstuff.page(params[:page]).per(10).includes(:user_actions)
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
      @recipes = Recipe.joins(:user_actions)
                       .where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Recipe' })
                       .page(params[:page]).per(10)
      @foodstuffs = Foodstuff.joins(:user_actions)
                             .where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Foodstuff' })
                             .page(params[:page]).per(10)
    when 'good'
      @recipes = Recipe.joins(:user_actions)
                       .where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Recipe' })
                       .page(params[:page]).per(10)
      @foodstuffs = Foodstuff.joins(:user_actions)
                             .where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Foodstuff' })
                             .page(params[:page]).per(10)
    when 'bad'
      @recipes = Recipe.joins(:user_actions)
                       .where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Recipe' })
                       .page(params[:page]).per(10)
      @foodstuffs = Foodstuff.joins(:user_actions)
                             .where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Foodstuff' })
                             .page(params[:page]).per(10)
    when 'kitchen_tools'
      kitchen_tool_ids = current_user.kitchen_tools.pluck(:id)
      @recipes = Recipe.joins(:kitchen_tools)
                       .where(kitchen_tools: { id: kitchen_tool_ids })
                       .page(params[:page]).per(10)
      @foodstuffs = nil # 食品には調理器具が関係しない場合、結果を空にする
    end
  end
  
end
