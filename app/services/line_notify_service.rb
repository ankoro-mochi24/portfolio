require 'httparty'  # HTTPartyを使用するためにライブラリを読み込む

class LineNotifyService
  include HTTParty  # HTTPartyモジュールをクラスにインクルードして、HTTPリクエストを簡単に送信できるようにする

  base_uri 'https://notify-api.line.me'  # LINE NotifyのベースURIを設定する

  def initialize(token = ENV['LINE_NOTIFY_TOKEN'])
    @token = token  # 初期化時に渡されたトークンをインスタンス変数に保存する。デフォルトでは環境変数からトークンを取得する
  end

  def send_notification(message)
    # LINE Notify APIに通知を送るためのオプションを設定
    options = {
      headers: { 
        'Authorization' => "Bearer #{@token}",  # トークンを使って認証ヘッダーを設定する
        'Content-Type' => 'application/x-www-form-urlencoded'  # データ形式を指定するヘッダー
      },
      body: { message: message }  # 送信するメッセージをリクエストボディに設定
    }
    # POSTリクエストを送信して、通知を送る
    self.class.post('/api/notify', options)
  end
end