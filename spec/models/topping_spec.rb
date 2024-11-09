require 'rails_helper'

RSpec.describe Topping, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      topping = FactoryBot.build(:topping, user: user, recipe: recipe)
      expect(topping).to be_valid
    end

    it 'nameがない場合、無効である' do
      topping = FactoryBot.build(:topping, name: nil, user: user, recipe: recipe)
      expect(topping).not_to be_valid
      expect(topping.errors[:name]).to include("を入力してください")
    end

    it 'nameが一意でない場合、無効である' do
      FactoryBot.create(:topping, name: "トッピング1", user: user, recipe: recipe)
      topping = FactoryBot.build(:topping, name: "トッピング1", user: user, recipe: recipe)
      expect(topping).not_to be_valid
      expect(topping.errors[:name]).to include("は同じレシピ内で重複しています")
    end
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'toppingが削除されたときに関連するuser_actionsも削除される' do
      topping = FactoryBot.create(:topping, user: user, recipe: recipe)
      user_action = FactoryBot.create(:user_action, user: user, actionable: topping)

      expect { topping.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:recipe_id, :name]).unique(true) }
  end
end
