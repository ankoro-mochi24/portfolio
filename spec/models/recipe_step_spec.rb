require 'rails_helper'

RSpec.describe RecipeStep, type: :model do
  let(:recipe) { FactoryBot.create(:recipe) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      recipe_step = FactoryBot.build(:recipe_step, recipe: recipe, text: '切る', step_image: nil)
      expect(recipe_step).to be_valid
    end

    it 'textがない場合、無効である' do
      recipe_step = FactoryBot.build(:recipe_step, recipe: recipe, text: nil)
      expect(recipe_step).not_to be_valid
      expect(recipe_step.errors[:text]).to include("を入力してください")
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    let(:recipe_step) { FactoryBot.create(:recipe_step, recipe: recipe) }

    it 'レシピと関連している' do
      expect(recipe_step.recipe).to eq(recipe)
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'レシピが削除されたときに関連するrecipe_stepも削除される' do
      FactoryBot.create(:recipe_step, recipe: recipe)
      expect { recipe.destroy }.to change { RecipeStep.count }.by(-1)
    end
  end

  # 画像削除のテスト
  describe '画像削除のテスト' do
    it 'remove_step_imageがtrueの場合、step_imageが削除される' do
      recipe_step = FactoryBot.create(:recipe_step, recipe: recipe, step_image: File.open(Rails.root.join('spec', 'fixtures', 'sample.jpg')))
      recipe_step.remove_step_image = 'true'
      recipe_step.save!
      
      # 画像ファイルが存在しないことを確認する
      expect(recipe_step.reload.step_image.file).to be_nil
    end

    it 'remove_step_imageがfalseの場合、step_imageは保持される' do
      recipe_step = FactoryBot.create(:recipe_step, recipe: recipe, step_image: File.open(Rails.root.join('spec', 'fixtures', 'sample.jpg')))
      recipe_step.remove_step_image = 'false'
      recipe_step.save!
      
      # 画像ファイルがまだ存在することを確認する
      expect(recipe_step.reload.step_image.file).not_to be_nil
    end
  end
end
