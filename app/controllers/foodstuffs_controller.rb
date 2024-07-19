class FoodstuffsController < ApplicationController
  before_action :set_foodstuff, only: %i[ show edit update destroy ]

  # GET /foodstuffs or /foodstuffs.json
  def index
    @foodstuffs = Foodstuff.all
  end

  # GET /foodstuffs/1 or /foodstuffs/1.json
  def show
  end

  # GET /foodstuffs/new
  def new
    @foodstuff = Foodstuff.new
  end

  # GET /foodstuffs/1/edit
  def edit
  end

  # POST /foodstuffs or /foodstuffs.json
  def create
    @foodstuff = Foodstuff.new(foodstuff_params)

    respond_to do |format|
      if @foodstuff.save
        format.html { redirect_to foodstuff_url(@foodstuff), notice: "Foodstuff was successfully created." }
        format.json { render :show, status: :created, location: @foodstuff }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @foodstuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /foodstuffs/1 or /foodstuffs/1.json
  def update
    respond_to do |format|
      if @foodstuff.update(foodstuff_params)
        format.html { redirect_to foodstuff_url(@foodstuff), notice: "Foodstuff was successfully updated." }
        format.json { render :show, status: :ok, location: @foodstuff }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @foodstuff.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /foodstuffs/1 or /foodstuffs/1.json
  def destroy
    @foodstuff.destroy

    respond_to do |format|
      format.html { redirect_to foodstuffs_url, notice: "Foodstuff was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_foodstuff
      @foodstuff = Foodstuff.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def foodstuff_params
      params.require(:foodstuff).permit(:name, :price, :description, :link, :image)
    end
end
