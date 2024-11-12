require 'rails_helper'

RSpec.describe LineNotifyController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /line_notify/authorize" do
    it "LINE Notify認証ページにリダイレクトされること" do
      get line_notify_authorize_path
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/https:\/\/notify-bot.line.me\/oauth\/authorize/)
    end
  end

  describe "GET /line_notify/callback" do
    context "有効なコールバックが受け取られた場合" do
      let(:valid_params) do
        {
          code: 'valid_code',
          state: user.id.to_s
        }
      end

      it "トークンが保存され、プロフィールページにリダイレクトされること" do
        response_body = {
          access_token: 'valid_access_token'
        }.to_json

        stub_request(:post, "https://notify-bot.line.me/oauth/token")
          .with(
            body: hash_including(code: "valid_code"),
            headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

        get line_notify_callback_path, params: valid_params

        user.reload
        expect(user.line_notify_token).to eq('valid_access_token')
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq(I18n.t("notices.line_notify_connected"))
      end
    end

    context "無効なコールバックが受け取られた場合" do
      let(:invalid_params) do
        {
          code: nil,
          state: user.id.to_s
        }
      end

      it "プロフィールページにエラーメッセージと共にリダイレクトされること" do
        stub_request(:post, "https://notify-bot.line.me/oauth/token")
          .to_return(status: 400, body: "", headers: {})

        get line_notify_callback_path, params: invalid_params

        expect(response).to redirect_to(profile_path)
        expect(flash[:alert]).to eq(I18n.t("errors.messages.line_notify_failed"))
      end
    end
  end

  describe "DELETE /line_notify/unlink" do
    context "ユーザーがLINE Notifyトークンを持っている場合" do
      before do
        user.update(line_notify_token: "valid_token")
        allow_any_instance_of(LineNotifyService).to receive(:send_notification).and_return(true)
      end

      it "連携解除の通知が送信され、トークンが削除されること" do
        delete line_notify_unlink_path
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq(I18n.t("notices.line_notify_unlinked"))

        user.reload
        expect(user.line_notify_token).to be_nil
      end
    end

    context "ユーザーがLINE Notifyトークンを持っていない場合" do
      it "プロフィールページにリダイレクトされ、エラーがないこと" do
        delete line_notify_unlink_path
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq(I18n.t("notices.line_notify_unlinked"))
      end
    end
  end
end
