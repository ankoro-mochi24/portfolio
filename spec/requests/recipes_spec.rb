# spec/requests/recipes_spec.rb

require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:kitchen_tool) { FactoryBot.create(:kitchen_tool) }
  let(:ingredient) { FactoryBot.create(:ingredient) }
  let!(:recipe) { FactoryBot.create(:recipe, user:, dish_image: fixture_file_upload("spec/fixtures/sample.jpg", "image/jpg")) }
  let!(:other_recipe) { FactoryBot.create(:recipe, user: other_user, dish_image: fixture_file_upload("spec/fixtures/sample.jpg", "image/jpg")) }

  before do
    sign_in user
  end

  describe "PATCH /recipes/:id" do
    context "ユーザーが自身のレシピを更新する場合" do
      let(:valid_params) do
        {
          recipe: {
            title: "新しいタイトル",
            dish_image: fixture_file_upload("spec/fixtures/sample.jpg", "image/jpg"),
            recipe_kitchen_tools_attributes: [{ kitchen_tool_name: "フライパン" }],
            recipe_ingredients_attributes: [{ ingredient_name: "塩" }]
          }
        }
      end
      let(:invalid_params) { { recipe: { title: "", dish_image: fixture_file_upload("spec/fixtures/sample.jpg", "image/jpg") } } }

      it "無効なパラメータで更新した場合、エラーメッセージが表示されること" do
        patch recipe_path(recipe), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("タイトルを入力してください")
      end

      it "有効なパラメータで更新した場合、リダイレクトされ、成功メッセージが表示されること" do
        patch recipe_path(recipe), params: valid_params
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.recipe_updated"))
      end
    end
  end

  describe "POST /recipes" do
    context "有効なパラメータの場合" do
      it "レシピが作成され、成功メッセージが表示されること" do
        post recipes_path,
             params: { recipe: { title: "New Recipe", dish_image: fixture_file_upload("spec/fixtures/sample.jpg", "image/jpg"), recipe_kitchen_tools_attributes: [{ kitchen_tool_name: kitchen_tool.name }],
                                 recipe_ingredients_attributes: [{ ingredient_name: ingredient.name }] } }
        expect(response).to redirect_to(recipe_path(Recipe.last))
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.recipe_created"))
      end
    end

    context "無効なパラメータの場合" do
      it "レシピが作成されず、エラーメッセージが表示されること" do
        post recipes_path, params: { recipe: { title: "" } }
        expect(response.body).to include(I18n.t("activerecord.errors.models.recipe.attributes.title.blank"))
      end
    end
  end

  describe "POST /recipes/:id/add_topping" do
    context "正常系" do
      it "トッピングが追加され、成功メッセージが表示されること" do
        post add_topping_recipe_path(recipe), params: { topping: { name: "テストトッピング" } }
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.topping_added"))
      end
    end

    context "異常系" do
      it "空の名前でトッピングを追加しようとした場合、エラーメッセージが表示されること" do
        post add_topping_recipe_path(recipe), params: { topping: { name: "" } }
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include(I18n.t("alerts.topping_add_failed"))
      end
    end
  end

  describe "DELETE /recipes/:id/remove_topping" do
    it "トッピングが削除され、成功メッセージが表示されること" do
      topping = recipe.toppings.create(name: "Sample Topping", user:)
      delete remove_topping_recipe_path(recipe, topping_id: topping.id), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("topping_#{topping.id}")
    end
  end

  describe "DELETE /recipes/:id" do
    context "ユーザーが自身のレシピを削除する場合" do
      it "レシピが削除され、成功メッセージが表示されること" do
        delete recipe_path(recipe)
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.recipe_deleted"))
      end
    end

    context "他のユーザーのレシピを削除しようとした場合" do
      it "削除が許可されず、エラーメッセージが表示されること" do
        delete recipe_path(other_recipe)
        follow_redirect!
        expect(response.body).to include(I18n.t("errors.messages.unauthorized_recipe"))
      end
    end
  end

  describe "GET /recipes/:id" do
    context "レシピが存在しない場合" do
      it "エラーメッセージが表示されること" do
        expect { get recipe_path(id: 9999) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "レシピが存在する場合" do
      it "レシピの詳細が表示されること" do
        get recipe_path(recipe)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(recipe.title)
      end
    end
  end
end
