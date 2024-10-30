require 'rails_helper'

RSpec.describe "ProfilesController#show", type: :request do
  describe "GET /profile" do
    context "ユーザーがサインインしている場合" do
      let(:user) { create(:user) }
      before do
        sign_in user
        get profile_path
      end

      it "ユーザー情報が表示されること" do
        expect(response.body).to include(user.name)
        expect(response.body).to include(user.email)
      end

      it "リクエストが成功すること" do
        expect(response).to have_http_status(:ok)
      end

      it "ユーザーの調理器具が表示されること" do
        user.kitchen_tools.each do |tool|
          expect(response.body).to include(tool.name)
        end
      end
    end

    context "ユーザーがサインインしていない場合" do
      before { get profile_path }

      it "ログインページにリダイレクトされること" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
