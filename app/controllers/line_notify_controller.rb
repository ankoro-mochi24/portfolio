class LineNotifyController < ApplicationController
  def authorize
    redirect_to "https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=#{ENV['LINE_NOTIFY_CLIENT_ID']}&redirect_uri=#{ENV['LINE_NOTIFY_REDIRECT_URI']}&scope=notify&state=#{current_user.id}", allow_other_host: true
  end

  def callback
    code = params[:code]
    user_id = params[:state]
    
    puts "Callback received with code=#{code}, user_id=#{user_id}"
    
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
  
    puts "HTTParty response: #{response.body}, status: #{response.code}"
  
    if response.code == 200
      access_token = response.parsed_response["access_token"]
      puts "Access token parsed: #{access_token}"
  
      user = User.find(user_id)
      if user.update_line_notify_token(access_token) # 新しい専用メソッドを使用
        puts "User updated successfully: #{user.line_notify_token}"
      else
        puts "Failed to update user: #{user.errors.full_messages.join(', ')}"
      end
  
      redirect_to profile_path, notice: I18n.t("notices.line_notify_connected")
    else
      puts "Failed to retrieve access token: #{response.body}"
      redirect_to profile_path, alert: I18n.t("errors.messages.line_notify_failed")
    end
  end

  def unlink
    if current_user.line_notify_token.present?
      LineNotifyService.new(current_user.line_notify_token).send_notification(I18n.t("notices.line_notify_unlinked"))
      if current_user.update_line_notify_token(nil) # 専用メソッドを利用してトークン削除
        redirect_to profile_path, notice: I18n.t("notices.line_notify_unlinked")
      else
        Rails.logger.error "Failed to unlink line_notify_token: #{current_user.errors.full_messages.join(', ')}"
        redirect_to profile_path, alert: I18n.t("errors.messages.line_notify_unlink_failed")
      end
    else
      redirect_to profile_path, notice: I18n.t("notices.line_notify_unlinked")
    end
  end
end
