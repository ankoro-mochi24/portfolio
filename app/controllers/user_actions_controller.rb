class UserActionsController < ApplicationController
  before_action :authenticate_user!

  def create
    Rails.logger.debug("params: #{params.inspect}")
    @action = current_user.user_actions.new(user_action_params)
    if @action.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path, notice: 'Action was successfully created.' }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'Failed to create action.' }
      end
    end
  end

  def destroy
    @action = current_user.user_actions.find(params[:id])
    @action.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: 'Action was successfully destroyed.' }
      format.json { head :no_content }
    end
  rescue => e
    logger.error "Failed to destroy action: #{e.message}"
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'Failed to destroy action.' }
      format.json { render json: { error: 'Failed to destroy action' }, status: :unprocessable_entity }
    end
  end

  private

  def user_action_params
    Rails.logger.debug("user_action_params: #{params[:user_action_data].inspect}")
    params.require(:user_action_data).permit(:action_type, :actionable_type, :actionable_id)
  end
end
