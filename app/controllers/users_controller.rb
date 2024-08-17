class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_layout
  
  def show
    @user = User.find(params[:id])
    @kitchen_tools = @user.kitchen_tools
  end

  def edit
    @user = User.find(params[:id])
    @kitchen_tools = KitchenTool.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end

  private

  def set_layout
    @use_sidebar = true # ここでサイドバー用のフラグを設定
  end

  def user_params
    params.require(:user).permit(:name, :email, user_kitchen_tools_attributes: [:id, :kitchen_tool_id, :_destroy])
  end
end
