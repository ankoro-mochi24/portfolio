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

    sort_content if params[:sort_by].present?
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

  def sort_content
    case params[:sort_by]
    when 'few_ingredients'
      @recipes = @recipes.joins(:recipe_ingredients)
                         .group('recipes.id')
                         .order('COUNT(recipe_ingredients.id) ASC')
    when 'easy_cooking'
      @recipes = @recipes.joins(:recipe_steps)
                         .group('recipes.id')
                         .order('COUNT(recipe_steps.id) ASC')
    when 'newest'
      @recipes = @recipes.order(created_at: :desc)
      @foodstuffs = @foodstuffs.order(created_at: :desc)
    when 'oldest'
      @recipes = @recipes.order(created_at: :asc)
      @foodstuffs = @foodstuffs.order(created_at: :asc)
    when 'most_good'
      @recipes = @recipes.left_outer_joins(:user_actions)
                         .group('recipes.id, recipes.title, recipes.dish_image, recipes.created_at')
                         .order(Arel.sql('COUNT(CASE WHEN user_actions.action_type = "good" AND user_actions.actionable_type = "Recipe" THEN 1 ELSE NULL END) DESC'))
      
      @foodstuffs = @foodstuffs.left_outer_joins(:user_actions)
                        .group('foodstuffs.id, foodstuffs.name, foodstuffs.price, foodstuffs.created_at')
                        .order(Arel.sql('COUNT(CASE WHEN user_actions.action_type = "good" AND user_actions.actionable_type = "Foodstuff" THEN 1 ELSE NULL END) DESC'))
    when 'most_bookmarks'
      @recipes = @recipes.left_outer_joins(:user_actions)
                          .group('recipes.id, recipes.title, recipes.dish_image, recipes.created_at')
                          .order(Arel.sql("COUNT(CASE WHEN user_actions.action_type = 'bookmark' AND user_actions.actionable_type = 'Recipe' THEN 1 ELSE NULL END) DESC"))

      @foodstuffs = @foodstuffs.left_outer_joins(:user_actions)
                          .group('foodstuffs.id, foodstuffs.name, foodstuffs.price, foodstuffs.created_at')
                          .order(Arel.sql("COUNT(CASE WHEN user_actions.action_type = 'bookmark' AND user_actions.actionable_type = 'Foodstuff' THEN 1 ELSE NULL END) DESC"))
    end
  end

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
