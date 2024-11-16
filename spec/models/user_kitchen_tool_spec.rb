require 'rails_helper'

RSpec.describe UserKitchenTool, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:kitchen_tool) { FactoryBot.create(:kitchen_tool) }

  before do
    described_class.delete_all
    User.delete_all
    KitchenTool.delete_all
  end

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect(user_kitchen_tool).to be_valid
    end

    it 'user_idがない場合、無効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user: nil, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect(user_kitchen_tool).not_to be_valid
      expect(user_kitchen_tool.errors[:user]).to include(I18n.t('errors.messages.required'))
    end

    it 'kitchen_tool_idがない場合、無効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user:, kitchen_tool: nil, kitchen_tool_name: nil)
      expect(user_kitchen_tool).not_to be_valid
      expect(user_kitchen_tool.errors[:kitchen_tool]).to include(I18n.t('errors.messages.required'))
    end

    it 'kitchen_tool_nameがない場合、無効である' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user:, kitchen_tool_name: nil)
      expect(user_kitchen_tool).not_to be_valid
      expect(user_kitchen_tool.errors[:kitchen_tool_name]).to include(I18n.t('errors.messages.blank'))
    end

    it 'userとkitchen_toolの組み合わせが一意でない場合、無効である' do
      FactoryBot.create(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      duplicate_user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect(duplicate_user_kitchen_tool).not_to be_valid
      expect(duplicate_user_kitchen_tool.errors[:user_id]).to include(I18n.t('activerecord.errors.models.user_kitchen_tool.attributes.user_id.taken'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it 'ユーザーと調理器具に関連している' do
      user_kitchen_tool = FactoryBot.build(:user_kitchen_tool, user:, kitchen_tool:)
      expect(user_kitchen_tool.user).to eq(user)
      expect(user_kitchen_tool.kitchen_tool).to eq(kitchen_tool)
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'userが削除されたときに関連するuser_kitchen_toolも削除される' do
      FactoryBot.create(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect { user.destroy }.to change(described_class, :count).by(-1)
    end

    it 'kitchen_toolが削除されたときに関連するuser_kitchen_toolも削除される' do
      FactoryBot.create(:user_kitchen_tool, user:, kitchen_tool:, kitchen_tool_name: kitchen_tool.name)
      expect { kitchen_tool.destroy }.to change(described_class, :count).by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index([:user_id, :kitchen_tool_id]).unique(true) }
  end
end
