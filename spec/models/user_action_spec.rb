require 'rails_helper'

RSpec.describe UserAction, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }
  let(:foodstuff) { FactoryBot.create(:foodstuff) }
  let(:topping) { FactoryBot.create(:topping) }

  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect(user_action).to be_valid
    end

    it 'action_typeがない場合、無効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: nil)
      expect(user_action).not_to be_valid
      expect(user_action.errors[:action_type]).to include(I18n.t('errors.messages.blank'))
    end

    it 'action_typeが無効な値の場合、無効である' do
      user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'invalid')
      expect(user_action).not_to be_valid
      expect(user_action.errors[:action_type]).to include(I18n.t('errors.messages.inclusion'))
    end

    it '同じユーザーが同じアイテムに対して同じaction_typeを持つ場合、無効である' do
      FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      duplicate_user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect(duplicate_user_action).not_to be_valid
      expect(duplicate_user_action.errors[:user_id]).to include(I18n.t('activerecord.errors.models.user_action.attributes.user_id.taken'))
    end

    it '同じユーザーが同じアイテムに対してgoodとbadを同時に持つことはできない' do
      FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      conflicting_user_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'bad')
      expect(conflicting_user_action).not_to be_valid
      expect(conflicting_user_action.errors[:base]).to include(
        I18n.t('activerecord.errors.models.user_action.messages.good_bad_conflict')
      )
    end
  end

  describe 'アソシエーションのテスト' do
    it { should belong_to(:user) }
    it 'actionableがポリモーフィック関連であることを確認する' do
      expect(UserAction.reflect_on_association(:actionable).options[:polymorphic]).to be_truthy
    end

    it 'actionableがRecipeモデルと関連付けられることを確認する' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect(user_action.actionable).to be_a(Recipe)
    end

    it 'actionableがFoodstuffモデルと関連付けられることを確認する' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: foodstuff, action_type: 'good')
      expect(user_action.actionable).to be_a(Foodstuff)
    end

    it 'actionableがToppingモデルと関連付けられることを確認する' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: topping, action_type: 'good')
      expect(user_action.actionable).to be_a(Topping)
    end
  end

  describe '削除時のテスト' do
    it 'userが削除されたときに関連するuser_actionsも削除される' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect { user.destroy }.to change { UserAction.count }.by(-1)
    end

    it 'actionableがRecipeモデルのインスタンスである場合、Recipeが削除されると関連するuser_actionsも削除される' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')
      expect { recipe.destroy }.to change { UserAction.count }.by(-1)
    end

    it 'actionableがFoodstuffモデルのインスタンスである場合、Foodstuffが削除されると関連するuser_actionsも削除される' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: foodstuff, action_type: 'good')
      expect { foodstuff.destroy }.to change { UserAction.count }.by(-1)
    end

    it 'actionableがToppingモデルのインスタンスである場合、Toppingが削除されると関連するuser_actionsも削除される' do
      user_action = FactoryBot.create(:user_action, user: user, actionable: topping, action_type: 'good')
      expect { topping.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:user_id, :actionable_type, :actionable_id, :action_type]).unique(true) }
  end
end
