# Line Notifyの通知
require 'httparty'

class LineNotifyService
  include HTTParty
  base_uri 'https://notify-api.line.me'

  def initialize(token)
    @token = token
  end

  def send_notification(message)
    Rails.logger.info "Sending LINE Notify message: #{message}"
    
    options = {
      headers: { 
        'Authorization' => "Bearer #{@token}",
        'Content-Type' => 'application/x-www-form-urlencoded'
      },
      body: { message: message }
    }

    response = self.class.post('/api/notify', options)

    Rails.logger.info "LINE Notify response: #{response.body}, status: #{response.code}"

    if response.success?
      Rails.logger.info "Notification sent successfully."
    else
      Rails.logger.error "Failed to send notification. Response: #{response.body}"
    end

    response
  end
end
