class FoodstuffsController < ApplicationController
  before_action :set_foodstuff, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[destroy] # 削除時のみ投稿者をチェック

  def index # /foodstuffs.json用
    @foodstuffs = Foodstuff.all

    respond_to do |format|
      format.json { render 'foodstuffs/index' }
    end
  end

  def show
    @commentable = @foodstuff
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
        format.html { redirect_to @foodstuff, notice: I18n.t("notices.foodstuff_created") }
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
        format.html { redirect_to @foodstuff, notice: I18n.t("notices.foodstuff_updated") }
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
      format.html { redirect_to root_path, notice: I18n.t("notices.foodstuff_deleted") }
      format.json { head :no_content }
    end
  end

  private

  # 共通のセットアップまたは制約を共有するためのコールバック
  def set_foodstuff
    @foodstuff = Foodstuff.find(params[:id])
  end

  # 投稿者のみが削除できるようにする認可メソッド
  def authorize_user!
    unless @foodstuff.user == current_user
      redirect_to root_path, alert: I18n.t('errors.messages.unauthorized_foodstuff')
    end
  end

  # ストロングパラメーター
  def foodstuff_params
    params.require(:foodstuff).permit(:name, :price, :description, :link, { image: [] })
  end
end
