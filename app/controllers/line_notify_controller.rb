# Line Notifyの認証
class LineNotifyController < ApplicationController
  def authorize
    Rails.logger.debug "Redirecting to: https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=#{ENV['LINE_NOTIFY_CLIENT_ID']}&redirect_uri=#{ENV['LINE_NOTIFY_REDIRECT_URI']}&scope=notify&state=#{current_user.id}"
    
    redirect_to "https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=#{ENV['LINE_NOTIFY_CLIENT_ID']}&redirect_uri=#{ENV['LINE_NOTIFY_REDIRECT_URI']}&scope=notify&state=#{current_user.id}", allow_other_host: true
  end

  def callback
    code = params[:code]
    user_id = params[:state]

    response = HTTParty.post("https://notify-bot.line.me/oauth/token", {
      body: {
        grant_type: "authorization_code",
        code: code,
        redirect_uri: ENV['LINE_NOTIFY_REDIRECT_URI'],
        client_id: ENV['LINE_NOTIFY_CLIENT_ID'],
        client_secret: ENV['LINE_NOTIFY_CLIENT_SECRET']
      },
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    })

    if response.code == 200
      access_token = response.parsed_response["access_token"]

      user = User.find(user_id)
      user.update(line_notify_token: access_token)

      redirect_to profile_path, notice: "LINE Notifyとの連携が完了しました。"
    else
      redirect_to profile_path, alert: "LINE Notifyとの連携に失敗しました。"
    end
  end

  def unlink
    if current_user.line_notify_token.present?
      LineNotifyService.new(current_user.line_notify_token).send_notification("LINE Notifyの連携を解除しました。")
      current_user.update(line_notify_token: nil)
    end
    
    redirect_to profile_path, notice: "LINE Notifyの連携を解除しました。"
  end
end
