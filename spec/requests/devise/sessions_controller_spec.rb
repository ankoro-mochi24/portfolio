require 'rails_helper'

RSpec.describe Devise::SessionsController, type: :request do
  let!(:user) { create(:user) }

  describe "GET /users/sign_in" do
    it "ログインページが正常に表示される" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ログイン")  # ログインページに「ログイン」というテキストが含まれているか確認
    end
  end

  describe "POST /users/sign_in" do
    context "有効な資格情報が与えられた場合" do
      it "ユーザーがログインし、ルートパスにリダイレクトされる" do
        post user_session_path, params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ログインに成功しました")
      end
    end

    context "無効な資格情報が与えられた場合" do
      it "ログインページがエラーと共に表示される" do
        post user_session_path, params: { user: { email: user.email, password: "wrongpassword" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("無効なメールアドレスまたはパスワードです")
      end
    end
  end

  describe "DELETE /users/sign_out" do
    before do
      sign_in user
    end

    it "ユーザーがログアウトし、ルートパスにリダイレクトされる" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("ログアウトに成功しました")
    end
  end
end
