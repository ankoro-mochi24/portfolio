require 'rails_helper'

RSpec.describe RecipeKitchenTool, type: :model do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user:) }
  let(:kitchen_tool) { create(:kitchen_tool) }

  before do
    # データの初期化
    described_class.delete_all
    Recipe.delete_all
    KitchenTool.delete_all
  end

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      recipe_kitchen_tool = build(:recipe_kitchen_tool, recipe:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect(recipe_kitchen_tool).to be_valid
    end

    it 'kitchen_tool_nameがない場合、無効である' do
      recipe_kitchen_tool = build(:recipe_kitchen_tool, recipe:, kitchen_tool_name: nil)
      expect(recipe_kitchen_tool).not_to be_valid
      expect(recipe_kitchen_tool.errors[:kitchen_tool_name]).to include(I18n.t('errors.messages.blank'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it 'レシピと調理器具に関連している' do
      recipe_kitchen_tool = build(:recipe_kitchen_tool, recipe:, kitchen_tool:)
      expect(recipe_kitchen_tool.recipe).to eq(recipe)
      expect(recipe_kitchen_tool.kitchen_tool).to eq(kitchen_tool)
    end
  end

  # 重複チェックのテスト
  describe '重複チェックのテスト' do
    it '同じrecipe_idとkitchen_tool_idの組み合わせは無効である' do
      create(:recipe_kitchen_tool, recipe:, kitchen_tool:)
      duplicate_recipe_kitchen_tool = build(:recipe_kitchen_tool, recipe:, kitchen_tool:)

      expect(duplicate_recipe_kitchen_tool).not_to be_valid
      expect(duplicate_recipe_kitchen_tool.errors[:recipe_id]).to include(I18n.t('activerecord.errors.models.recipe_kitchen_tool.attributes.recipe_id.taken'))
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'レシピが削除されたときに関連するrecipe_kitchen_toolも削除される' do
      create(:recipe_kitchen_tool, recipe:, kitchen_tool:)
      another_kitchen_tool = create(:kitchen_tool)
      create(:recipe_kitchen_tool, recipe:, kitchen_tool: another_kitchen_tool)

      # 削除前のカウント
      initial_count = described_class.count
      # レシピ削除によって削除されるレコードの数を確認
      expect { recipe.destroy }.to change(described_class, :count).from(initial_count).to(0)
    end

    it '調理器具が削除されると関連するrecipe_kitchen_toolも削除される' do
      create(:recipe_kitchen_tool, recipe:, kitchen_tool:)
      expect { kitchen_tool.destroy }.to change(described_class, :count).by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index([:recipe_id, :kitchen_tool_id]).unique(true) }
  end
end
