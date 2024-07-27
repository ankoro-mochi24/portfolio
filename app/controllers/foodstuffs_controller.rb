class FoodstuffsController < ApplicationController
  before_action :set_foodstuff, only: %i[show edit update destroy]

  # 食品リストの表示
  def index
    @foodstuffs = Foodstuff.all

    respond_to do |format|
      format.json { render 'foodstuffs/index' } # index.json.jbuilder を使用
    end
  end

  # 特定の食品の詳細表示
  def show
  end

  # 新しい食品の作成フォームを表示
  def new
    @foodstuff = Foodstuff.new
  end

  # 特定の食品の編集フォームを表示
  def edit
  end

  # 新しい食品を作成
  def create
    @foodstuff = Foodstuff.new(foodstuff_params)
    @foodstuff.user = current_user # current_userを適切に設定する

    respond_to do |format|
      if @foodstuff.save
        format.html { redirect_to @foodstuff, notice: "食品が正常に作成されました。" }
        format.json { render :show, status: :created, location: @foodstuff }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @foodstuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # 特定の食品を更新
  def update
    respond_to do |format|
      if @foodstuff.update(foodstuff_params)
        format.html { redirect_to @foodstuff, notice: "食品が正常に更新されました。" }
        format.json { render :show, status: :ok, location: @foodstuff }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @foodstuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # 特定の食品を削除
  def destroy
    @foodstuff.destroy
    respond_to do |format|
      format.html { redirect_to foodstuffs_url, notice: "食品が正常に削除されました。" }
      format.json { head :no_content }
    end
  end

  private

  # 共通のセットアップまたは制約を共有するためのコールバック
  def set_foodstuff
    @foodstuff = Foodstuff.find(params[:id])
  end

  # 信頼できるパラメータのみを許可する
  def foodstuff_params
    params.require(:foodstuff).permit(:name, :price, :description, :link, {image: []})
  end
end
