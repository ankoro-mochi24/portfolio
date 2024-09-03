class UserActionsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!

  def create
    @user_action = current_user.user_actions.new(user_action_params)
    remove_opposite_action(@user_action)
    
    if @user_action.save
      # このアクションの種類（いいね、ブックマークなど）に対する総数を取得
      @action_count = @user_action.actionable.user_actions.where(action_type: @user_action.action_type).count
      
      # LINEに通知を送るためのメソッドを呼び出す
      send_line_notification(@user_action)
      
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
    
    # アクションを削除した後に、残りのアクション数を再計算
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
    # 許可するパラメータを指定
    params.require(:user_action).permit(:action_type, :actionable_type, :actionable_id)
  end

  def remove_opposite_action(user_action)
    # "good"をした場合は"bad"を削除、"bad"をした場合は"good"を削除する
    opposite_action_type = user_action.action_type == 'good' ? 'bad' : 'good'
    opposite_action = current_user.user_actions.find_by(actionable: user_action.actionable, action_type: opposite_action_type)
    opposite_action&.destroy
  end

  def send_line_notification(user_action)
    # 通知を送る対象が現在のユーザーの投稿であるかを確認
    if user_action.actionable.user == user_action.user
      # LINEに通知するメッセージを作成
      message = case user_action.action_type
                when 'good'
                  if user_action.actionable.is_a?(Recipe)
                    "あなたのレシピ『#{user_action.actionable.title}』が#{current_user.name}さんにいいねされました！"
                  elsif user_action.actionable.is_a?(Foodstuff)
                    "あなたのおすすめ食品『#{user_action.actionable.name}』が#{current_user.name}さんにいいねされました！"
                  end
                when 'bookmark'
                  if user_action.actionable.is_a?(Recipe)
                    "あなたのレシピ『#{user_action.actionable.title}』が#{current_user.name}さんにブックマークされました！"
                  elsif user_action.actionable.is_a?(Foodstuff)
                    "あなたのおすすめ食品『#{user_action.actionable.name}』が#{current_user.name}さんにブックマークされました！"
                  end
                else
                  nil
                end
  
      # メッセージが存在する場合のみ通知を送信
      LineNotifyService.new.send_notification(message) if message.present?
    end
  end
end
