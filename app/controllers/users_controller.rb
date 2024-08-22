class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_layout, only: [:show, :edit]

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
end