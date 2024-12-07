class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :posts]
  before_action :set_view, only: [:posts]

  def show
    @kitchen_tools = @user.kitchen_tools.includes(:user_kitchen_tools).order('user_kitchen_tools.id ASC')
    @recipes = @user.recipes
    @foodstuffs = @user.foodstuffs
  end

  def edit
    @user.user_kitchen_tools = @user.user_kitchen_tools.order(:id)
    @user.user_kitchen_tools.each do |user_kitchen_tool|
      user_kitchen_tool.kitchen_tool_name = user_kitchen_tool.kitchen_tool.name if user_kitchen_tool.kitchen_tool.present?
    end
    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
  end

  def update
    # パスワード変更の有無を確認
    password_params = params[:user].slice(:password, :password_confirmation, :current_password).values
    if password_params.any?(&:present?)
      # パスワード変更を伴う更新
      if @user.update_with_password(user_params)
        process_user_kitchen_tools
        redirect_to profile_path, notice: t('notices.profile_updated')
      else
        handle_update_failure
      end
    else
      # パスワード変更なしでの更新
      if @user.update(user_params.except(:password, :password_confirmation, :current_password))
        process_user_kitchen_tools
        redirect_to profile_path, notice: t('notices.profile_updated')
      else
        handle_update_failure
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: t('notices.profile_deleted')
  end

  def posts
    @recipes = @user.recipes.page(params[:page]).per(10)
    @foodstuffs = @user.foodstuffs.page(params[:page]).per(10)

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

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :current_password,
      user_kitchen_tools_attributes: [:id, :kitchen_tool_id, :_destroy, :kitchen_tool_name]
    )
  end

  def process_user_kitchen_tools
    # 新しく追加された調理器具の処理
    @user.user_kitchen_tools.each do |ukt|
      if ukt.kitchen_tool_name.present? && ukt.kitchen_tool.nil?
        ukt.set_kitchen_tool
        ukt.save
      end
    end
  end

  def handle_update_failure
    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
    render :edit, status: :unprocessable_entity
  end
end
