class FoodstuffsController < ApplicationController
  before_action :set_foodstuff, only: %i[show edit update destroy]

  def index # /foodstuffs.json用
    @foodstuffs = Foodstuff.all

    respond_to do |format|
      format.json { render 'foodstuffs/index' }
    end
  end

  def show
  end

  def new
    @foodstuff = Foodstuff.new
  end

  def edit
  end

  def create
    @foodstuff = Foodstuff.new(foodstuff_params)
    @foodstuff.user = current_user

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

  # ストロングパラメーター
  def foodstuff_params
    params.require(:foodstuff).permit(:name, :price, :description, :link, {image: []})
  end
end
