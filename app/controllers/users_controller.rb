class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :bookmarked_recipes, :bookmarked_foodstuffs, :good_recipes, :bad_recipes, :good_foodstuffs, :bad_foodstuffs]
  before_action :set_layout, only: [:show, :edit, :bookmarked_recipes, :bookmarked_foodstuffs, :good_recipes, :bad_recipes, :good_foodstuffs, :bad_foodstuffs]
  before_action :set_sidebar_counts, only: [:show, :edit, :bookmarked_recipes, :bookmarked_foodstuffs, :good_recipes, :bad_recipes, :good_foodstuffs, :bad_foodstuffs]

  def show
    @kitchen_tools = @user.kitchen_tools
    @recipes = @user.recipes
    @foodstuffs = @user.foodstuffs
  end

  def edit
    @user.user_kitchen_tools.each do |user_kitchen_tool|
      user_kitchen_tool.kitchen_tool_name = user_kitchen_tool.kitchen_tool.name if user_kitchen_tool.kitchen_tool.present?
    end

    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'ユーザー情報が更新されました。'
    else
      @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def bookmarked_recipes
    @bookmarked_recipes = @user.user_actions.where(action_type: 'bookmark', actionable_type: 'Recipe').map(&:actionable)
  end

  def bookmarked_foodstuffs
    @bookmarked_foodstuffs = @user.user_actions.where(action_type: 'bookmark', actionable_type: 'Foodstuff').map(&:actionable)
  end

  def good_recipes
    @good_recipes = @user.user_actions.where(action_type: 'good', actionable_type: 'Recipe').map(&:actionable)
  end

  def bad_recipes
    @bad_recipes = @user.user_actions.where(action_type: 'bad', actionable_type: 'Recipe').map(&:actionable)
  end

  def good_foodstuffs
    @good_foodstuffs = @user.user_actions.where(action_type: 'good', actionable_type: 'Foodstuff').map(&:actionable)
  end

  def bad_foodstuffs
    @bad_foodstuffs = @user.user_actions.where(action_type: 'bad', actionable_type: 'Foodstuff').map(&:actionable)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name, 
      :email,
      user_kitchen_tools_attributes: [:id, :kitchen_tool_id, :_destroy, :kitchen_tool_name]
    )
  end

  def set_layout
    @use_sidebar = true
  end

  def set_sidebar_counts
    @bookmark_recipes_count = @user.user_actions.where(action_type: 'bookmark', actionable_type: 'Recipe').count
    @bookmark_foodstuffs_count = @user.user_actions.where(action_type: 'bookmark', actionable_type: 'Foodstuff').count
    @good_recipes_count = @user.user_actions.where(action_type: 'good', actionable_type: 'Recipe').count
    @bad_recipes_count = @user.user_actions.where(action_type: 'bad', actionable_type: 'Recipe').count
    @good_foodstuffs_count = @user.user_actions.where(action_type: 'good', actionable_type: 'Foodstuff').count
    @bad_foodstuffs_count = @user.user_actions.where(action_type: 'bad', actionable_type: 'Foodstuff').count
  end
end
