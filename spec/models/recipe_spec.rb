require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:user) { create(:user) }
  let(:kitchen_tool) { create(:kitchen_tool) }
  let(:ingredient) { create(:ingredient) }

  # バリデーションのテスト
  describe "バリデーションのテスト" do
    it "titleがあり、関連するuser、kitchen_tools、ingredientsがある場合、有効である" do
      recipe = build(:recipe, user:)
      recipe.recipe_kitchen_tools.build(kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      recipe.recipe_ingredients.build(ingredient:, ingredient_name: ingredient.name)
      expect(recipe).to be_valid
    end

    it "titleがない場合、無効である" do
      recipe = build(:recipe, title: nil, user:)
      recipe.recipe_kitchen_tools.build(kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect(recipe).not_to be_valid
    end

    it "kitchen_toolsが1つもない場合、無効である" do
      recipe = build(:recipe, user:)
      recipe.recipe_kitchen_tools.clear # kitchen_toolsをクリアしてテスト
      recipe.recipe_ingredients.build(ingredient:, ingredient_name: ingredient.name)
      expect(recipe).not_to be_valid
      expect(recipe.errors[:recipe_kitchen_tools]).to include('を最低1つ追加してください')
    end
  end

  # アソシエーションのテスト
  describe "アソシエーションのテスト" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
    it { is_expected.to have_many(:ingredients).through(:recipe_ingredients) }
    it { is_expected.to have_many(:recipe_kitchen_tools).dependent(:destroy) }
    it { is_expected.to have_many(:kitchen_tools).through(:recipe_kitchen_tools) }
    it { is_expected.to have_many(:recipe_steps).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:user_actions).dependent(:destroy) }
  end

  # ネストされた属性のテスト
  describe "ネストされた属性のテスト" do
    it "recipe_stepsをネストされた属性として受け入れることができる" do
      recipe = create(:recipe, user:)
      recipe_params = {
        recipe_steps_attributes: [{ text: "ステップ1" }, { text: "ステップ2" }]
      }
      recipe.update(recipe_params)
      expect(recipe.recipe_steps.size).to eq 2
    end

    it "recipe_ingredientsをネストされた属性として受け入れることができる" do
      recipe = create(:recipe, user:)
      recipe.recipe_ingredients.destroy_all # 余分なデータをクリア
      recipe_params = {
        recipe_ingredients_attributes: [{ ingredient_id: ingredient.id, ingredient_name: ingredient.name }]
      }
      recipe.update(recipe_params)
      expect(recipe.recipe_ingredients.size).to eq 1
    end

    it "recipe_kitchen_toolsをネストされた属性として受け入れることができる" do
      recipe = create(:recipe, user:)
      recipe.recipe_kitchen_tools.destroy_all # 余分なデータをクリア
      recipe_params = {
        recipe_kitchen_tools_attributes: [{ kitchen_tool_id: kitchen_tool.id, kitchen_tool_name: kitchen_tool.name }]
      }
      recipe.update(recipe_params)
      expect(recipe.recipe_kitchen_tools.size).to eq 1
    end
  end

  # コールバックのテスト
  describe "コールバックのテスト" do
    it "新規レシピ作成時、白米が自動的に材料として追加される" do
      recipe = create(:recipe, user:)
      expect(recipe.recipe_ingredients.map(&:ingredient_name)).to include("白米")
    end
  end
end
