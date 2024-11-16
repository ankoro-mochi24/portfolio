require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /profile" do
    context "ユーザーがサインインしている場合" do
      before { get profile_path }

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
      before do
        sign_out user
        get profile_path
      end

      it "ログインページにリダイレクトされること" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /profile/edit" do
    it "編集ページが表示され、正しい要素が含まれていること" do
      get edit_profile_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('profiles.edit.title'))
      expect(response.body).to include(I18n.t('profiles.edit.name'))
      expect(response.body).to include(I18n.t('profiles.edit.email'))
      expect(response.body).to include(I18n.t('profiles.edit.password'))
      expect(response.body).to include(I18n.t('profiles.edit.kitchen_tools'))
    end
  end

  describe "PATCH /profile" do
    context "有効なパラメータで更新した場合" do
      let(:valid_params) do
        { user: { name: "新しい名前", email: "new_email@example.com" } }
      end

      it "ユーザー情報が更新され、リダイレクトされること" do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(profile_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('notices.profile_updated'))
        user.reload
        expect(user.name).to eq("新しい名前")
        expect(user.email).to eq("new_email@example.com")
      end
    end

    context "無効なパラメータで更新した場合" do
      let(:invalid_params) do
        { user: { name: "", email: "invalid_email" } }
      end

      it "エラーメッセージと共に編集ページが再表示されること" do
        patch profile_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('profiles.edit.error'))
        expect(response.body).to include(I18n.t('errors.messages.blank', attribute: I18n.t('profiles.edit.name')))
      end
    end
  end

  describe "DELETE /profile" do
    it "アカウントが削除され、トップページにリダイレクトされること" do
      delete profile_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('notices.profile_deleted'))
      expect(User).not_to exist(user.id)
    end
  end

  describe "GET /profile/posts" do
    let!(:recipe) { create(:recipe, user:, title: "ユーザーのレシピ") }
    let!(:foodstuff) { create(:foodstuff, user:, name: "ユーザーの食品") }

    it "ユーザーの投稿したレシピと食品が表示されること" do
      get posts_profile_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('profiles.posts.title'))
      expect(response.body).to include(recipe.title)
      expect(response.body).to include(foodstuff.name)
    end

    context "ビューが'レシピ'に設定されている場合" do
      it "レシピのみが表示され、食品は表示されないこと" do
        get posts_profile_path, params: { view: 'recipes' }
        expect(response.body).to include(recipe.title)
        expect(response.body).not_to include(foodstuff.name)
      end
    end

    context "ビューが'食品'に設定されている場合" do
      it "食品のみが表示され、レシピは表示されないこと" do
        get posts_profile_path, params: { view: 'foodstuffs' }
        expect(response.body).to include(foodstuff.name)
        expect(response.body).not_to include(recipe.title)
      end
    end
  end
end
