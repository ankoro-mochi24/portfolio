class UserActionsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!

  def create
    @user_action = current_user.user_actions.new(user_action_params)
    remove_opposite_action(@user_action)
    if @user_action.save
      @action_count = @user_action.actionable.user_actions.where(action_type: @user_action.action_type).count
      set_filter_counts
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @user_action.actionable, notice: "#{@user_action.action_type} added." }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @user_action.actionable, alert: "Unable to perform this action." }
      end
    end
  end
  
  def destroy
    @user_action = current_user.user_actions.find(params[:id])
    @actionable = @user_action.actionable
    @action_type = @user_action.action_type
    @user_action.destroy
    @action_count = @actionable.user_actions.where(action_type: @action_type).count
    set_filter_counts
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @actionable, notice: "#{@action_type} removed." }
    end
  end

  private

  def user_action_params
    params.require(:user_action).permit(:action_type, :actionable_type, :actionable_id)
  end

  def remove_opposite_action(user_action)
    opposite_action_type = user_action.action_type == 'good' ? 'bad' : 'good'
    opposite_action = current_user.user_actions.find_by(actionable: user_action.actionable, action_type: opposite_action_type)
    opposite_action&.destroy
  end
end
