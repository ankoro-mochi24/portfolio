require 'rails_helper'

RSpec.describe "UserActions", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: other_user) }
  let(:foodstuff) { FactoryBot.create(:foodstuff, user: other_user) }
  let(:topping) { FactoryBot.create(:topping, recipe:, user: other_user) }
  let(:user_action) { FactoryBot.create(:user_action, user:, actionable: recipe, action_type: 'good') }

  before do
    sign_in user
  end

  describe "POST /recipes/:id/user_actions" do
    context "正常系" do
      it "レシピに対してgoodを追加できること" do
        post recipe_user_actions_path(recipe), params: {
          user_action: { action_type: "good", actionable_type: "Recipe", actionable_id: recipe.id }
        }
        follow_redirect!
        expect(response.body).to include(I18n.t('user_actions.success.added', action_type: I18n.t('user_actions.action_type_texts.good')))
      end

      it "食品に対してbookmarkを追加できること" do
        post foodstuff_user_actions_path(foodstuff), params: {
          user_action: { action_type: "bookmark", actionable_type: "Foodstuff", actionable_id: foodstuff.id }
        }
        follow_redirect!
        expect(response.body).to include(I18n.t('user_actions.success.added', action_type: I18n.t('user_actions.action_type_texts.bookmark')))
      end

      it "トッピングに対してbadを追加できること" do
        post topping_user_actions_path(topping), params: {
          user_action: { action_type: "bad", actionable_type: "Topping", actionable_id: topping.id }
        }
        follow_redirect!
        expect(response.body).to include(I18n.t('user_actions.success.added', action_type: I18n.t('user_actions.action_type_texts.bad')))
      end
    end

    context "異常系" do
      it "同じアクションを重複して追加しようとするとエラーが表示されること" do
        FactoryBot.create(:user_action, user:, actionable: recipe, action_type: "good")

        post recipe_user_actions_path(recipe), params: {
          user_action: { action_type: "good", actionable_type: "Recipe", actionable_id: recipe.id }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('activerecord.errors.models.user_action.attributes.user_id.taken'))
      end

      it "無効なaction_typeの場合、エラーが表示されること" do
        post recipe_user_actions_path(recipe), params: {
          user_action: { action_type: "invalid", actionable_type: "Recipe", actionable_id: recipe.id }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include(I18n.t('errors.messages.inclusion'))
      end

      it "同時にgoodとbadを追加しようとするとエラーが表示されること" do
        FactoryBot.create(:user_action, user:, actionable: recipe, action_type: "good")

        post recipe_user_actions_path(recipe), params: {
          user_action: { action_type: "bad", actionable_type: "Recipe", actionable_id: recipe.id }
        }

        expect(response).to have_http_status(:found) # 302 Found
        follow_redirect!
        expect(response.body).to include(I18n.t('user_actions.success.added', action_type: I18n.t('user_actions.action_type_texts.bad')))
      end

      it "未ログイン状態でリクエストを送るとリダイレクトされる" do
        sign_out user
        post recipe_user_actions_path(recipe), params: {
          user_action: { action_type: "good", actionable_type: "Recipe", actionable_id: recipe.id }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /recipes/:id/user_actions/:id" do
    context "正常系" do
      it "自分のアクションを削除できること" do
        delete recipe_user_action_path(recipe, user_action)
        expect(response).to redirect_to(recipe_path(recipe))
        expect(UserAction.find_by(id: user_action.id)).to be_nil
      end
    end

    context "異常系" do
      it "他のユーザーが作成したアクションを削除しようとするとエラーになる" do
        action = FactoryBot.create(:user_action, user: other_user, actionable: recipe, action_type: "good")
        delete recipe_user_action_path(recipe, action)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "Turbo Stream形式のレスポンス確認" do
    it "アクションを作成するとTurbo Streamレスポンスが返される" do
      post recipe_user_actions_path(recipe), params: {
        user_action: { action_type: "good", actionable_type: "Recipe", actionable_id: recipe.id }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
    end

    it "アクションを削除するとTurbo Streamレスポンスが返される" do
      delete recipe_user_action_path(recipe, user_action), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
    end
  end
end
