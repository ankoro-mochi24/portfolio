class UserActionsController < ApplicationController
  include ActionView::RecordIdentifier # 追加
  before_action :authenticate_user!

  def create
    @user_action = current_user.user_actions.new(user_action_params)
    if @user_action.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("#{dom_id(@user_action.actionable)}_#{@user_action.action_type}_actions", partial: 'shared/user_action', locals: { actionable: @user_action.actionable, action_type: @user_action.action_type })
        end
        format.html { redirect_to @user_action.actionable, notice: "#{@user_action.action_type} added." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("#{dom_id(@user_action.actionable)}_#{@user_action.action_type}_actions", partial: 'shared/user_action', locals: { actionable: @user_action.actionable, action_type: @user_action.action_type })
        end
        format.html { redirect_to @user_action.actionable, alert: "Unable to perform this action." }
      end
    end
  end

  def destroy
    @user_action = current_user.user_actions.find(params[:id])
    @actionable = @user_action.actionable
    action_type = @user_action.action_type
    @user_action.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("#{dom_id(@actionable)}_#{action_type}_actions", partial: 'shared/user_action', locals: { actionable: @actionable, action_type: action_type })
      end
      format.html { redirect_to @actionable, notice: "#{action_type} removed." }
    end
  end

  private

  def user_action_params
    params.require(:user_action).permit(:action_type, :actionable_type, :actionable_id)
  end
end
