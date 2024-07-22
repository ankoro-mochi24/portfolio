class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_steps.build
    @recipe.recipe_ingredients.build
    @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user

    if save_ingredients_and_kitchen_tools(@recipe) && @recipe.save
      redirect_to @recipe, notice: 'レシピが投稿されました。'
    else
      @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def show
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

    if save_ingredients_and_kitchen_tools(@recipe) && @recipe.save
      redirect_to @recipe, notice: 'レシピが更新されました。'
    else
      @recipe.recipe_kitchen_tools.build if @recipe.recipe_kitchen_tools.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: 'レシピが削除されました。'
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
      :remove_dish_image,
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
        ri.ingredient = ingredient
      end
    end
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
end
