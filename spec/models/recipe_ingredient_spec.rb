require 'rails_helper'

RSpec.describe RecipeIngredient, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user:) }
  let(:ingredient1) { FactoryBot.create(:ingredient) }
  let(:ingredient2) { FactoryBot.create(:ingredient) }

  before do
    described_class.delete_all
    Recipe.delete_all
    Ingredient.delete_all
  end

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe:, ingredient: ingredient1)
      expect(recipe_ingredient).to be_valid
    end

    it 'recipeがない場合、無効である' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe: nil, ingredient: ingredient1)
      expect(recipe_ingredient).not_to be_valid
      expect(recipe_ingredient.errors[:recipe]).to include(I18n.t('errors.messages.required'))
    end

    it 'ingredientがない場合、無効である' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe:, ingredient: nil)
      expect(recipe_ingredient).not_to be_valid
      expect(recipe_ingredient.errors[:ingredient]).to include(I18n.t('errors.messages.required'))
    end

    it '同じrecipe_idとingredient_idの組み合わせは無効である' do
      FactoryBot.create(:recipe_ingredient, recipe:, ingredient: ingredient1)
      duplicate_recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe:, ingredient: ingredient1)

      expect(duplicate_recipe_ingredient).not_to be_valid
      expect(duplicate_recipe_ingredient.errors[:recipe_id]).to include(I18n.t('activerecord.errors.models.recipe_ingredient.attributes.recipe_id.taken'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it 'レシピと材料に関連している' do
      recipe_ingredient = FactoryBot.build(:recipe_ingredient, recipe:, ingredient: ingredient1)
      expect(recipe_ingredient.recipe).to eq(recipe)
      expect(recipe_ingredient.ingredient).to eq(ingredient1)
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    before do
      described_class.delete_all
      recipe.recipe_ingredients.destroy_all
      FactoryBot.create(:recipe_ingredient, recipe:, ingredient: ingredient1)
      FactoryBot.create(:recipe_ingredient, recipe:, ingredient: ingredient2)
    end

    it 'レシピが削除されたときに関連するrecipe_ingredientがすべて削除され、ingredient自体は削除されない' do
      expect(recipe.recipe_ingredients.count).to eq(2)

      # レシピ削除により RecipeIngredient が 2 件削除されることを確認
      expect { recipe.destroy }.to change(described_class, :count).by(-2)

      # Ingredient 自体は削除されていないことを確認
      expect(Ingredient.exists?(ingredient1.id)).to be true
      expect(Ingredient.exists?(ingredient2.id)).to be true
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index([:recipe_id, :ingredient_id]).unique(true) }
  end
end
