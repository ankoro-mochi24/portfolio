class UserActionsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!

  def create
    @user_action = current_user.user_actions.new(user_action_params)
    remove_opposite_action(@user_action)

    if @user_action.save
      @action_count = @user_action.actionable.user_actions.where(action_type: @user_action.action_type).count
      send_line_notification(@user_action)
      set_filter_counts

      respond_to do |format|
        format.turbo_stream
        format.html do
          if @user_action.actionable_type == "Topping"
            redirect_to recipe_path(@user_action.actionable.recipe), notice: t("user_actions.success.added", action_type: t("user_actions.action_type_texts.#{@user_action.action_type}"))
          else
            redirect_to @user_action.actionable, notice: t("user_actions.success.added", action_type: t("user_actions.action_type_texts.#{@user_action.action_type}"))
          end
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@user_action),
            partial: "error",
            locals: { errors: @user_action.errors.full_messages }
          ), status: :unprocessable_entity
        end
        format.html do
          render plain: @user_action.errors.full_messages.to_sentence, status: :unprocessable_entity
        end
        format.json { render json: { errors: @user_action.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_action = current_user.user_actions.find_by(id: params[:id])

    # 自分のアクションではない場合は403を返す
    if @user_action.nil?
      head :forbidden
      return
    end

    @actionable = @user_action.actionable
    @action_type = @user_action.action_type

    @user_action.destroy
    @action_count = @actionable.user_actions.where(action_type: @action_type).count

    set_filter_counts
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @actionable, notice: t("user_actions.success.removed", action_type: t("user_actions.action_type_texts.#{@action_type}")) }
      format.json { render json: { message: t("user_actions.success.removed", action_type: t("user_actions.action_type_texts.#{@action_type}")), action_count: @action_count }, status: :ok }
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

  def send_line_notification(user_action)
    token = user_action.actionable.user.line_notify_token
    return unless token.present?

    message =
      case user_action.action_type
      when 'good'
        t("user_actions.notifications.good")
      when 'bookmark'
        t("user_actions.notifications.bookmark")
      end
    LineNotifyService.new(token).send_notification(message) if message.present?
  end
end
