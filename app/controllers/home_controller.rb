class HomeController < ApplicationController
  before_action :set_layout, only: [:top]

  def top
    if params[:query].present?
      query = params[:query]
      logger.info "検索クエリ: #{query}" # 検索クエリのログ出力
      @recipes = Recipe.search(query)
      logger.info "検索結果（レシピ）: #{@recipes.to_a}" # レシピ検索結果のログ出力
      @foodstuffs = Foodstuff.search(query)
      logger.info "検索結果（食品）: #{@foodstuffs.to_a}" # 食品検索結果のログ出力
    else
      @recipes = Recipe.all
      @foodstuffs = Foodstuff.all
    end
  end

  def cookrice
  end

  private

  def set_layout
    @use_split_layout = true
  end
end
