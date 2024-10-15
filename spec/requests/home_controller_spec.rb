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
    context "when visiting the top page" do
      it "renders the top page successfully" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("レシピ")
        expect(response.body).to include("食品")
      end
    end

    context "when searching by query" do
      it "returns the search results" do
        get root_path, params: { query: recipe.title }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
      end
    end

    context "when sorting by newest" do
      it "sorts recipes and foodstuffs by newest" do
        get root_path, params: { sort_by: 'newest' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
        expect(response.body).to include(foodstuff.name)
      end
    end

    context "when filtering by bookmarks" do
      it "filters recipes by bookmarks" do
        sign_in user
        user.user_actions.create!(actionable: recipe, action_type: 'bookmark')
        get root_path, params: { filter: 'bookmarks' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include(recipe.title)
      end
    end
  end
end
