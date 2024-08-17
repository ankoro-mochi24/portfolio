class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :set_layout, only: [:show, :edit]

  def show
    @user = User.find(params[:id])
    @kitchen_tools = @user.kitchen_tools
  end

  def edit
    @user.user_kitchen_tools.each do |ukt|
      ukt.kitchen_tool_name = ukt.kitchen_tool.name if ukt.kitchen_tool.present?
    end
    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
  end

  def update
    @user.assign_attributes(user_params)

    @user.user_kitchen_tools.each do |tool|
      tool.mark_for_destruction if tool._destroy == "1"
    end

    if @user.save
      redirect_to user_path(@user), notice: 'プロフィールが更新されました。'
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
end
