require 'rails_helper'

RSpec.describe RecipeIngredient, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }
  let(:ingredient1) { FactoryBot.create(:ingredient) }
  let(:ingredient2) { FactoryBot.create(:ingredient) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
      expect(recipe_ingredient).to be_valid
    end

    it 'recipeがない場合、無効である' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: nil, ingredient: ingredient1)
      expect(recipe_ingredient).not_to be_valid
      expect(recipe_ingredient.errors[:recipe]).to include("が必要です")
    end

    it 'ingredientがない場合でも有効である（オプション）' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: recipe, ingredient: nil)
      expect(recipe_ingredient).to be_valid
    end

    it '同じrecipe_idとingredient_idの組み合わせは無効である' do
      FactoryBot.create(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
      duplicate_recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
      
      expect(duplicate_recipe_ingredient).not_to be_valid
      expect(duplicate_recipe_ingredient.errors[:recipe_id]).to include("この材料は既にレシピに追加されています")
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it 'レシピと材料に関連している' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
      expect(recipe_ingredient.recipe).to eq(recipe)
      expect(recipe_ingredient.ingredient).to eq(ingredient1)
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    before do
      # 必要なデータのみを作成するために余分なデータが作成されないようにFactoryBot.createでなくFactoryBot.buildを使用する
      recipe.recipe_ingredients.destroy_all
      FactoryBot.create(:recipe_ingredient, recipe: recipe, ingredient: ingredient1)
      FactoryBot.create(:recipe_ingredient, recipe: recipe, ingredient: ingredient2)
    end

    it 'レシピが削除されたときに関連するrecipe_ingredientがすべて削除され、ingredient自体は削除されない' do
      # レシピに関連するRecipeIngredientが2つあることを確認
      expect(recipe.recipe_ingredients.count).to eq(2)

      # レシピを削除
      expect { recipe.destroy }.to change { RecipeIngredient.count }.by(-2)

      # Ingredient自体は削除されていないことを確認
      expect(Ingredient.exists?(ingredient1.id)).to be true
      expect(Ingredient.exists?(ingredient2.id)).to be true
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:recipe_id, :ingredient_id]).unique(true) }
  end
end
