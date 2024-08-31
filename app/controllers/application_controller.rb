class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name]) # サインアップ時にnameパラメータを許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name]) # アカウント更新時にnameパラメータを許可
  end

  protected

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
