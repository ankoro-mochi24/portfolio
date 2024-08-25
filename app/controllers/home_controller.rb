class HomeController < ApplicationController
  before_action :set_view, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      @recipes = Recipe.search(query, page: params[:page], per_page: 10)
      @foodstuffs = Foodstuff.search(query, page: params[:page], per_page: 10)
    else
      @recipes = Recipe.page(params[:page]).per(10)
      @foodstuffs = Foodstuff.page(params[:page]).per(10)
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
      # 持っている調理器具で作れるレシピに絞り込み
      @recipes = @recipes.joins(:kitchen_tools).where(kitchen_tools: { id: current_user.kitchen_tools.pluck(:id) })
      @foodstuffs = nil # 食品は関連しないのでnilに設定
    end
  end

  def set_filter_counts
    @bookmark_count = {
      recipes: Recipe.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Recipe' }).count,
      foodstuffs: Foodstuff.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bookmark', actionable_type: 'Foodstuff' }).count
    }
    
    @good_count = {
      recipes: Recipe.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Recipe' }).count,
      foodstuffs: Foodstuff.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'good', actionable_type: 'Foodstuff' }).count
    }
    
    @bad_count = {
      recipes: Recipe.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Recipe' }).count,
      foodstuffs: Foodstuff.joins(:user_actions).where(user_actions: { user_id: current_user.id, action_type: 'bad', actionable_type: 'Foodstuff' }).count
    }

    @kitchen_tools_count = Recipe.joins(:kitchen_tools).where(kitchen_tools: { id: current_user.kitchen_tools.pluck(:id) }).count
  end
end
