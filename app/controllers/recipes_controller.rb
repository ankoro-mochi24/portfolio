class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :add_topping, :remove_topping]

  def index # /recipes.json用
    @recipes = Recipe.all

    respond_to do |format|
      format.json { render 'recipes/index' }
    end
  end

  def show
    @commentable = @recipe
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_steps.build

    if params[:foodstuff_name].present?
      ingredient = Ingredient.find_or_initialize_by(name: params[:foodstuff_name])
      @recipe.recipe_ingredients.build(ingredient: ingredient, ingredient_name: ingredient.name)
    end
  end  

  def edit
    @recipe.recipe_ingredients.each do |ri|
      ri.ingredient_name = ri.ingredient.name if ri.ingredient.present?
    end
    @recipe.recipe_kitchen_tools.each do |rkt|
      rkt.kitchen_tool_name = rkt.kitchen_tool.name if rkt.kitchen_tool.present?
    end
    @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
  
    # デバッグ用ログ
    Rails.logger.info "Received recipe_params: #{recipe_params.inspect}"
    Rails.logger.info "Recipe Ingredients from params: #{params[:recipe][:recipe_ingredients_attributes].inspect}" if params[:recipe][:recipe_ingredients_attributes]
    Rails.logger.info "Recipe Kitchen Tools from params: #{params[:recipe][:recipe_kitchen_tools_attributes].inspect}" if params[:recipe][:recipe_kitchen_tools_attributes]
  
    respond_to do |format|
      if save_ingredients_and_kitchen_tools(@recipe) && @recipe.save
        format.html { redirect_to @recipe, notice: I18n.t('notices.recipe_created') }
        format.json { render :show, status: :created, location: @recipe }
      else
        # デバッグ: バリデーションエラーの内容を出力
        Rails.logger.info "Recipe save failed. Errors: #{@recipe.errors.full_messages}"
        Rails.logger.info "Recipe Ingredients after processing: #{@recipe.recipe_ingredients.inspect}"
        Rails.logger.info "Recipe Kitchen Tools after processing: #{@recipe.recipe_kitchen_tools.inspect}"
  
        @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @recipe.assign_attributes(recipe_params)

    @recipe.recipe_steps.each do |step|
      step.mark_for_destruction if step._destroy == "1"
    end

    @recipe.recipe_kitchen_tools.each do |tool|
      tool.mark_for_destruction if tool._destroy == "1"
    end

    @recipe.recipe_ingredients.each do |ingredient|
      ingredient.mark_for_destruction if ingredient._destroy == "1"
    end

    respond_to do |format|
      if save_ingredients_and_kitchen_tools(@recipe) && @recipe.save
        format.html { redirect_to @recipe, notice: I18n.t('notices.recipe_updated') }
        format.json { render :show, status: :ok, location: @recipe }
      else
        @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @recipe.user == current_user
      @recipe.destroy
      respond_to do |format|
        format.html { redirect_to root_path, notice: I18n.t('notices.recipe_deleted') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: I18n.t('errors.messages.unauthorized_recipe') }
        format.json { render json: { error: I18n.t('errors.messages.unauthorized_recipe') }, status: :forbidden }
      end
    end
  end

  def add_topping
    @topping = @recipe.toppings.find_or_initialize_by(name: topping_params[:name])
    @topping.user ||= current_user

    respond_to do |format|
      if @topping.persisted? || @topping.save
        format.turbo_stream
        format.html { redirect_to @recipe, notice: I18n.t('notices.topping_added') }
      else
        format.html { redirect_to @recipe, alert: I18n.t('alerts.topping_add_failed') }
      end
    end
  end

  def remove_topping
    Rails.logger.info "Removing Topping ID: #{params[:topping_id]}"
    @topping = @recipe.toppings.find_by(id: params[:topping_id])

    if @topping
      @topping.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @recipe, notice: I18n.t('notices.topping_removed') }
      end
    else
      redirect_to @recipe, alert: I18n.t('errors.messages.not_found')
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :dish_image,
      :dish_image_cache,
      recipe_steps_attributes: [:id, :text, :step_image, :step_image_cache, :remove_step_image, :_destroy],
      recipe_ingredients_attributes: [:id, :ingredient_id, :_destroy, :ingredient_name],
      recipe_kitchen_tools_attributes: [:id, :kitchen_tool_id, :_destroy, :kitchen_tool_name]
    )
  end

  def save_ingredients_and_kitchen_tools(recipe)
    save_ingredients(recipe) && save_kitchen_tools(recipe)
  end

  def save_ingredients(recipe)
    recipe.recipe_ingredients = recipe.recipe_ingredients.reject { |ri| ri.ingredient_name.blank? }
  
    recipe.recipe_ingredients.each do |ri|
      if ri.ingredient_name.present?
        ingredient = Ingredient.find_or_create_by(name: ri.ingredient_name)
        Rails.logger.info "Found or created ingredient: #{ingredient.inspect}"
        ri.ingredient = ingredient
      end
    end
  
    # 重複する `ingredient_id` を除外
    recipe.recipe_ingredients = recipe.recipe_ingredients.uniq { |ri| ri.ingredient_id }
    Rails.logger.info "Final RecipeIngredients: #{recipe.recipe_ingredients.inspect}"
  end

  def save_kitchen_tools(recipe)
    recipe.recipe_kitchen_tools = recipe.recipe_kitchen_tools.reject { |rkt| rkt.kitchen_tool_name.blank? }
    recipe.recipe_kitchen_tools.each do |rkt|
      if rkt.kitchen_tool_name.present?
        kitchen_tool = KitchenTool.find_or_create_by(name: rkt.kitchen_tool_name)
        rkt.kitchen_tool = kitchen_tool
      end
    end
  end

  def topping_params
    params.require(:topping).permit(:name)
  end
end
