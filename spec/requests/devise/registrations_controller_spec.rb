require 'rails_helper'

RSpec.describe Devise::RegistrationsController, type: :request do
  let!(:user) { create(:user) }

  before do
    I18n.locale = :ja  # 日本語ロケールに設定
  end

  describe "GET /users/sign_up" do
    it "renders the sign up page successfully" do
      get new_user_registration_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('devise.registrations.new.title'))  # "サインアップ"を期待
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post user_registration_path, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      it "renders the sign up page with errors" do
        post user_registration_path, params: { user: attributes_for(:user, email: '') }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('errors.messages.blank'))  # "を入力してください"
      end
    end
  end

  describe "DELETE /users" do
    before do
      sign_in user
    end

    it "deletes the user" do
      expect {
        delete user_registration_path
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end
end
