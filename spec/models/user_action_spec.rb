require 'rails_helper'

RSpec.describe UserAction, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect(user_action).to be_valid
    end

    it 'action_typeがない場合、無効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: nil)
      expect(user_action).not_to be_valid
      expect(user_action.errors[:action_type]).to include("を入力してください")
    end

    it 'action_typeが無効な値の場合、無効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'invalid')
      expect(user_action).not_to be_valid
      expect(user_action.errors[:action_type]).to include("は一覧にありません")
    end

    it '同じユーザーが同じアイテムに対して同じaction_typeを持つ場合、無効である' do
      FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      duplicate_user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect(duplicate_user_action).not_to be_valid
      expect(duplicate_user_action.errors[:user_id]).to include("はすでに存在します")
    end

    it '同じユーザーが同じアイテムに対してgoodとbadを同時に持つことはできない' do
      FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      conflicting_user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'bad')
      expect(conflicting_user_action).not_to be_valid
      expect(conflicting_user_action.errors[:base]).to include("Cannot have both good and bad actions at the same time")
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'userが削除されたときに関連するuser_actionsも削除される' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect { user.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:user_id, :actionable_type, :actionable_id, :action_type]).unique(true) }
  end
end
