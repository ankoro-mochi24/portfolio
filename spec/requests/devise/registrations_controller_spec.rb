require 'rails_helper'

RSpec.describe Devise::RegistrationsController, type: :request do
  let!(:user) { create(:user) }

  before do
    I18n.locale = :ja  # 日本語ロケールに設定
  end

  describe "GET /users/sign_up" do
    it "サインアップページが正常に表示される" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('devise.registrations.new.title'))  # "サインアップ"を期待
    end
  end

  describe "POST /users" do
    context "有効なパラメータが与えられた場合" do
      it "新しいユーザーが作成される" do
        expect {
          post user_registration_path, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "無効なパラメータが与えられた場合" do
      it "エラーと共にサインアップページが表示される" do
        post user_registration_path, params: { user: attributes_for(:user, email: '') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('errors.messages.blank'))  # "を入力してください"のエラーメッセージを期待
      end
    end
  end

  describe "DELETE /users" do
    before do
      sign_in user
    end

    it "ユーザーが削除される" do
      expect {
        delete user_registration_path
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end
end
