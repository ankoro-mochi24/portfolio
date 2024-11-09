require 'rails_helper'

RSpec.describe "ホームページのリクエスト", type: :request do
  describe "GET /" do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      Rails.cache.clear
    end

    it "GET / にアクセスでき、ステータスコード200が返る" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "トップページにレシピと食品の両方のセクションが表示される" do
      get root_path
      expect(response.body).to include(I18n.t('recipes.index.title'))
      expect(response.body).to include(I18n.t('foodstuffs.index.title'))
    end

    it "GET /cookrice にアクセスでき、ステータスコード200が返る" do
      get "/cookrice"
      expect(response).to have_http_status(:ok)
    end

    context "検索機能" do
      let!(:recipe1) { FactoryBot.create(:recipe, title: "テストレシピ1") }
      let!(:recipe2) { FactoryBot.create(:recipe, title: "検索対象レシピ") }

      before do
        Recipe.reindex
        Recipe.search_index.refresh
      end

      it "クエリに一致するレシピが表示される" do
        get root_path, params: { query: "検索対象" }
        expect(response.body).to include("検索対象レシピ")
      end
    end

    context "フィルター数の確認" do
      it 'ブックマーク数が正しい' do
        bookmark_user = FactoryBot.create(:user_with_actions, actions_count: 1)
        recipe = FactoryBot.create(:recipe, user: bookmark_user)
        bookmark_user.user_actions.first.update(action_type: 'bookmark', actionable: recipe)
        bookmark_count = UserAction.where(user: bookmark_user, action_type: 'bookmark', actionable: recipe).count
        expect(bookmark_count).to eq(1)
      end
    end

    context "フィルター機能" do
      let!(:good_recipe) { FactoryBot.create(:recipe, title: "良い評価のレシピ") }
      let!(:bookmarked_recipe) { FactoryBot.create(:recipe, title: "ブックマークしたレシピ") }

      before do
        good_recipe.user_actions.create(user: user, action_type: 'good')
        bookmarked_recipe.user_actions.create(user: user, action_type: 'bookmark')
        Recipe.reindex
        Recipe.search_index.refresh
      end

      it "良い評価のレシピのみが表示される" do
        get root_path, params: { filter: 'good' }
        expect(response.body).to include("良い評価のレシピ")
        expect(response.body).not_to include("ブックマークしたレシピ")
      end

      it "ブックマークしたレシピのみが表示される" do
        get root_path, params: { filter: 'bookmarks' }
        expect(response.body).to include("ブックマークしたレシピ")
        expect(response.body).not_to include("良い評価のレシピ")
      end
    end

    context "ページネーション" do
      before do
        # ページネーション用のテストデータ生成前にインデックスをリセット
        Recipe.search_index.delete if Recipe.search_index.exists?
        Recipe.search_index.create

        # 必要な15件のレシピを生成してインデックス
        FactoryBot.create_list(:recipe, 15)
        Recipe.reindex
        Recipe.search_index.refresh

        # デバッグ用の出力
        recipes_in_index = Recipe.search("*").results
      end

      it "1ページに10件のレシピが表示される" do
        get root_path, params: { page: 1 }
        recipe_count = response.body.scan(/class="recipe-item"/).size
        expect(recipe_count).to eq(10)
      end

      it "2ページ目に残りの5件のレシピが表示される" do
        get root_path, params: { page: 2 }
        recipe_count = response.body.scan(/class="recipe-item"/).size
        expect(recipe_count).to eq(5)
      end
    end

    context "ビューの設定" do
      it 'レシピのみが表示され、食品が表示されない' do
        get root_path, params: { view: 'recipes' }
        expect(response.body).to include(I18n.t('recipes.index.title'))
        expect(response.body).not_to include(I18n.t('foodstuffs.index.title'))
      end

      it '食品のみが表示され、レシピが表示されない' do
        get root_path, params: { view: 'foodstuffs' }
        expect(response.body).to include(I18n.t('foodstuffs.index.title'))
        expect(response.body).not_to include(I18n.t('recipes.index.title'))
      end
    end

    context "ソート機能" do
      let!(:old_recipe) { FactoryBot.create(:recipe, title: "古いレシピ", created_at: 1.day.ago) }
      let!(:new_recipe) { FactoryBot.create(:recipe, title: "新しいレシピ", created_at: Time.zone.now) }

      before do
        Recipe.reindex
        Recipe.search_index.refresh
      end

      it "古い順でソートされる" do
        get root_path, params: { sort_by: 'oldest' }
        expect(response.body.index(old_recipe.title)).to be < response.body.index(new_recipe.title)
      end

      it "新しい順でソートされる" do
        get root_path, params: { sort_by: 'newest' }
        expect(response.body.index(new_recipe.title)).to be < response.body.index(old_recipe.title)
      end
    end
  end
end
