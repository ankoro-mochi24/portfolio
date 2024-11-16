require 'rails_helper'

RSpec.describe RecipeStep, type: :model do
  let(:recipe) { create(:recipe) }
  let(:recipe_step) { build(:recipe_step, recipe:, text: '切る') }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      expect(recipe_step).to be_valid
    end

    it 'textがない場合、無効である' do
      recipe_step.text = nil
      expect(recipe_step).not_to be_valid
      expect(recipe_step.errors[:text]).to include(I18n.t('errors.messages.blank'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it 'レシピと関連している' do
      recipe_step.save
      expect(recipe_step.recipe).to eq(recipe)
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'レシピが削除されたときに関連するrecipe_stepも削除される' do
      recipe_step.save
      expect { recipe.destroy }.to change(described_class, :count).by(-1)
    end
  end

  # 画像削除機能のテスト
  describe '画像削除機能のテスト' do
    let(:image_path) { Rails.root.join("spec/fixtures/sample.jpg") }

    it 'remove_step_imageがtrueの場合、step_imageが削除される' do
      recipe_step.step_image = File.open(image_path)
      recipe_step.remove_step_image = 'true'
      recipe_step.save!
      expect(recipe_step.reload.step_image.file).to be_nil
    end

    it 'remove_step_imageがfalseの場合、step_imageは保持される' do
      recipe_step.step_image = File.open(image_path)
      recipe_step.remove_step_image = 'false'
      recipe_step.save!
      expect(recipe_step.reload.step_image.file).not_to be_nil
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index(:recipe_id) }
  end
end
