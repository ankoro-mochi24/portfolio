require 'rails_helper'  # Railsのヘルパーを読み込む
require 'webmock/rspec'  # WebMockの設定も合わせて読み込む

RSpec.describe LineNotifyController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /line_notify/callback" do
    context "有効なコールバックが受け取られた場合" do
      let(:valid_params) do
        {
          code: 'valid_code',
          state: user.id.to_s
        }
      end

      it "コールバックを処理し、プロフィールページにリダイレクトする" do
        response_body = {
          access_token: 'valid_access_token'
        }.to_json

        stub_request(:post, "https://notify-bot.line.me/oauth/token")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

        get line_notify_callback_path, params: valid_params

        expect(user.reload.line_notify_token).to eq('valid_access_token')
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq('LINE Notifyとの連携が完了しました。')
      end
    end

    context "無効なコールバックが受け取られた場合" do
      let(:invalid_params) do
        {
          code: nil,
          state: user.id.to_s
        }
      end

      it "コールバック処理に失敗し、エラーと共にリダイレクトする" do
        stub_request(:post, "https://notify-bot.line.me/oauth/token")
          .to_return(status: 400, body: "", headers: {})

        get line_notify_callback_path, params: invalid_params

        expect(response).to redirect_to(profile_path)
        expect(flash[:alert]).to eq('LINE Notifyとの連携に失敗しました。')
      end
    end
  end
end
