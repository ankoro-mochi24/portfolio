# レシピと食品をインデックスに追加するためにreindexを実行
RSpec.configure do |config|
  config.before(:each) do
    Recipe.reindex
    Foodstuff.reindex
  end
end

RSpec.describe HomeController, type: :request do
  let!(:user) { create(:user) }
  let!(:recipe) { create(:recipe, user: user) }
  let!(:foodstuff) { create(:foodstuff, user: user) }

  before do
    # 検索対象となるレシピと食品のインデックスを再作成
    Recipe.reindex
    Foodstuff.reindex
    Recipe.search_index.refresh
    Foodstuff.search_index.refresh
  end

  describe "GET /" do
    context "トップページを訪れたとき" do
      it "トップページが正常に表示される" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("レシピ")
        expect(response.body).to include("食品")
      end
    end

    context "クエリで検索したとき" do
      it "検索結果が返される" do
        get root_path, params: { query: recipe.title }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
      end
    end

    context "最新順でソートしたとき" do
      it "レシピと食品が最新順でソートされる" do
        get root_path, params: { sort_by: 'newest' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
        expect(response.body).to include(foodstuff.name)
      end
    end

    context "ブックマークでフィルタリングしたとき" do
      it "レシピがブックマークでフィルタリングされる" do
        sign_in user
        user.user_actions.create!(actionable: recipe, action_type: 'bookmark')
        get root_path, params: { filter: 'bookmarks' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
      end
    end
  end
end
