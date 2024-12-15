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
    # パスワード変更が必要かどうかを確認
    password_params = user_params.slice(:password, :password_confirmation, :current_password)
    if password_params.values.any?(&:present?)
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
    @user.user_kitchen_tools.each do |ukt|
      # フォームから送信された名前
      params_tool_name = ukt.kitchen_tool_name
  
      # 現在のデータベースに存在する名前
      current_tool_name = ukt.kitchen_tool&.name
  
      # 名前が異なる場合、対応するkitchen_toolを更新または関連付け
      if params_tool_name.present? && params_tool_name != current_tool_name
        # 新しいkitchen_toolを探すか作成
        kitchen_tool = KitchenTool.find_or_create_by(name: params_tool_name)
        ukt.kitchen_tool = kitchen_tool
        ukt.save
      end
    end
  end

  def handle_update_failure
    @user.user_kitchen_tools.build if @user.user_kitchen_tools.empty?
    render :edit, status: :unprocessable_entity
  end
end
