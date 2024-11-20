class LineNotifyController < ApplicationController
  def authorize
    redirect_to "https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=#{ENV.fetch('LINE_NOTIFY_CLIENT_ID', nil)}&redirect_uri=#{ENV.fetch('LINE_NOTIFY_REDIRECT_URI', nil)}&scope=notify&state=#{current_user.id}", 
                allow_other_host: true
  end

  def callback
    code = params[:code]
    user_id = params[:state]
    
    response = HTTParty.post("https://notify-bot.line.me/oauth/token", {
      body: {
        grant_type: "authorization_code",
        code: code,
        redirect_uri: ENV.fetch('LINE_NOTIFY_REDIRECT_URI', nil),
        client_id: ENV.fetch('LINE_NOTIFY_CLIENT_ID', nil),
        client_secret: ENV.fetch('LINE_NOTIFY_CLIENT_SECRET', nil)
      },
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    })
  
    if response.code == 200
      access_token = response.parsed_response["access_token"]
      user = User.find(user_id)
      if user.update_line_notify_token(access_token, current_user)
        redirect_to profile_path, notice: I18n.t("notices.line_notify_connected")
      else
        redirect_to profile_path, alert: I18n.t("errors.messages.line_notify_failed")
      end
    else
      redirect_to profile_path, alert: I18n.t("errors.messages.line_notify_failed")
    end
  end

  def unlink
    if current_user.line_notify_token.present?
      LineNotifyService.new(current_user.line_notify_token).send_notification(I18n.t("notices.line_notify_unlinked"))
      if current_user.update_line_notify_token(nil, current_user)
        redirect_to profile_path, notice: I18n.t("notices.line_notify_unlinked")
      else
        redirect_to profile_path, alert: I18n.t("errors.messages.line_notify_unlink_failed")
      end
    else
      redirect_to profile_path, notice: I18n.t("notices.line_notify_unlinked")
    end
  end
end
