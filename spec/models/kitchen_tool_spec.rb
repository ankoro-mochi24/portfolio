require 'rails_helper'

RSpec.describe KitchenTool, type: :model do
  let(:kitchen_tool) { FactoryBot.create(:kitchen_tool) }

  before(:each) do
    KitchenTool.delete_all
  end

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it "名前があれば有効である" do
      expect(kitchen_tool).to be_valid
    end

    it "名前がない場合は無効である" do
      kitchen_tool.name = nil
      expect(kitchen_tool).not_to be_valid
      expect(kitchen_tool.errors[:name]).to include(I18n.t('errors.messages.blank'))
    end

    it "重複する名前の場合は無効である" do
      duplicate_kitchen_tool = FactoryBot.build(:kitchen_tool, name: kitchen_tool.name)
      expect(duplicate_kitchen_tool).not_to be_valid
      expect(duplicate_kitchen_tool.errors[:name]).to include(I18n.t('errors.messages.taken'))
    end

    it "名前が特定の長さを超える場合は無効である" do
      kitchen_tool.name = "a" * 256  # 仮に255文字が上限の場合
      expect(kitchen_tool).not_to be_valid
    end

    it "名前が空白のみの場合は無効である" do
      kitchen_tool.name = "   "
      expect(kitchen_tool).not_to be_valid
      expect(kitchen_tool.errors[:name]).to include(I18n.t('errors.messages.blank'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it { should have_many(:recipe_kitchen_tools).dependent(:destroy) }
    it { should have_many(:recipes).through(:recipe_kitchen_tools) }
    it { should have_many(:user_kitchen_tools).dependent(:destroy) }
    it { should have_many(:users).through(:user_kitchen_tools) }

    it 'キッチンツールが削除されたとき、関連するrecipe_kitchen_toolsも削除される' do
      recipe = FactoryBot.create(:recipe)
      FactoryBot.create(:recipe_kitchen_tool, recipe: recipe, kitchen_tool: kitchen_tool, kitchen_tool_name: kitchen_tool.name)

      expect { kitchen_tool.destroy }.to change { RecipeKitchenTool.count }.by(-1)
    end

    it 'キッチンツールが削除されたとき、関連するuser_kitchen_toolsも削除される' do
      user = FactoryBot.create(:user)
      FactoryBot.create(:user_kitchen_tool, user: user, kitchen_tool: kitchen_tool)

      kitchen_tool.destroy
      expect(UserKitchenTool.where(kitchen_tool_id: kitchen_tool.id)).to be_empty
    end
  end
end
