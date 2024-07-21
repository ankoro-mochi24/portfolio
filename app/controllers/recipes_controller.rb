class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_steps.build
    @recipe.recipe_ingredients.build
    @recipe.recipe_kitchen_tools.build
    @ingredients = Ingredient.all
    @kitchen_tools = KitchenTool.all
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user # ユーザーがログインしていることを前提としています

    if @recipe.save
      redirect_to @recipe, notice: 'レシピが投稿されました。'
    else
      @ingredients = Ingredient.all
      @kitchen_tools = KitchenTool.all
      render :new
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title,
      :dish_image,
      recipe_steps_attributes: [:id, :text, :step_image, :_destroy],
      recipe_ingredients_attributes: [:id, :ingredient_id, :_destroy],
      recipe_kitchen_tools_attributes: [:id, :kitchen_tool_id, :_destroy]
    )
  end
end
