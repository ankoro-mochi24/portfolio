require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }
  let(:kitchen_tool) { create(:kitchen_tool, name: "炊飯器") }
  let!(:user_kitchen_tool) { create(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: "炊飯器") }

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

  describe "PATCH /profile (調理器具更新のテスト)" do
    context "既存の調理器具名を変更した場合" do
      let(:update_params) do
        {
          user: {
            user_kitchen_tools_attributes: {
              "0" => {
                id: user_kitchen_tool.id,
                kitchen_tool_id: kitchen_tool.id,
                kitchen_tool_name: "ケトル",
                _destroy: "false"
              }
            }
          }
        }
      end

      it "kitchen_tool_nameが更新されること" do
        patch profile_path, params: update_params
        expect(response).to redirect_to(profile_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('notices.profile_updated'))
        expect(user_kitchen_tool.reload.kitchen_tool.name).to eq("ケトル")
      end
    end

    context "新しい調理器具を追加した場合" do
      let(:add_params) do
        {
          user: {
            user_kitchen_tools_attributes: {
              "0" => {
                id: user_kitchen_tool.id,
                kitchen_tool_id: kitchen_tool.id,
                kitchen_tool_name: "炊飯器",
                _destroy: "false"
              },
              "1" => {
                kitchen_tool_id: "",
                kitchen_tool_name: "オーブン",
                _destroy: "false"
              }
            }
          }
        }
      end

      it "新しい調理器具が追加されること" do
        patch profile_path, params: add_params
        expect(response).to redirect_to(profile_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('notices.profile_updated'))
        expect(user.kitchen_tools.pluck(:name)).to include("炊飯器", "オーブン")
      end
    end

    context "調理器具を削除した場合" do
      let(:delete_params) do
        {
          user: {
            user_kitchen_tools_attributes: {
              "0" => {
                id: user_kitchen_tool.id,
                kitchen_tool_id: kitchen_tool.id,
                kitchen_tool_name: "炊飯器",
                _destroy: "true"
              }
            }
          }
        }
      end

      it "調理器具が削除されること" do
        patch profile_path, params: delete_params
        expect(response).to redirect_to(profile_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('notices.profile_updated'))
        expect(user.kitchen_tools).to be_empty
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
