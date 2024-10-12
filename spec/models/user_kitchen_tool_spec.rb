require 'rails_helper'

RSpec.describe UserKitchenTool, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:kitchen_tool) { FactoryBot.create(:kitchen_tool) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user: user, kitchen_tool: kitchen_tool)
      expect(user_kitchen_tool).to be_valid
    end

    it 'user_idがない場合、無効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user: nil, kitchen_tool: kitchen_tool)
      expect(user_kitchen_tool).not_to be_valid
      expect(user_kitchen_tool.errors[:user]).to include("が必要です")
    end

    it 'kitchen_tool_idがない場合、無効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user: user, kitchen_tool: nil)
      expect(user_kitchen_tool).not_to be_valid
      expect(user_kitchen_tool.errors[:kitchen_tool]).to include("が必要です")
    end

    it 'userとkitchen_toolの組み合わせが一意でない場合、無効である' do
      FactoryBot.create(:user_kitchen_tool, user: user, kitchen_tool: kitchen_tool)
      duplicate_user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user: user, kitchen_tool: kitchen_tool)
      expect(duplicate_user_kitchen_tool).not_to be_valid
      expect(duplicate_user_kitchen_tool.errors[:user_id]).to include("はすでに存在します")
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'userが削除されたときに関連するuser_kitchen_toolsも削除される' do
      user_kitchen_tool = FactoryBot.create(:user_kitchen_tool, user: user, kitchen_tool: kitchen_tool)
      expect { user.destroy }.to change { UserKitchenTool.count }.by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:user_id, :kitchen_tool_id]).unique(true) }
  end
end
