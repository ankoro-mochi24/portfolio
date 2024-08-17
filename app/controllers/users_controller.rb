class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_layout, only: [:show, :edit]

  def show
    @kitchen_tools = @user.kitchen_tools
  end

  def edit
    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
  end

  def update
    if update_user_kitchen_tools(@user, user_params)
      if @user.update(user_params)
        redirect_to user_path(@user), notice: 'プロフィールが更新されました。'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_layout
    @use_sidebar = true
  end

  def user_params
    params.require(:user).permit(:name, :email, user_kitchen_tools_attributes: [:id, :kitchen_tool_id, :kitchen_tool_name, :_destroy])
  end

  def update_user_kitchen_tools(user, user_params)
    user.user_kitchen_tools.each do |user_kitchen_tool|
      kitchen_tool_name = user_kitchen_tool.kitchen_tool_name
      if kitchen_tool_name.present?
        kitchen_tool = KitchenTool.find_or_create_by(name: kitchen_tool_name)
        user_kitchen_tool.kitchen_tool = kitchen_tool
      end
    end
    true
  rescue StandardError => e
    Rails.logger.error "Error updating kitchen tools: #{e.message}"
    false
  end
end
