require 'rails_helper'

RSpec.describe Foodstuff, type: :model do
  let(:user) { FactoryBot.create(:user) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が存在する場合、有効である' do
      foodstuff = FactoryBot.build(:foodstuff, user: user)
      expect(foodstuff).to be_valid
    end

    it 'nameがない場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, name: nil, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:name]).to include("名前を入力してください")
    end

    it 'priceがない場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, price: nil, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include("価格を入力してください")
    end

    it 'priceが負の値の場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, price: -1, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include("価格は0以上の値にしてください")
    end

    it 'priceが整数でない場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, price: 10.5, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include("価格は整数で入力してください")
    end

    it 'linkがない場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, link: nil, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:link]).to include("リンクを入力してください")
    end

    it 'imageがない場合、無効である' do
      foodstuff = FactoryBot.build(:foodstuff, image: nil, user: user)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:image]).to include("画像をアップロードしてください")
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:user_actions).dependent(:destroy) }
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'userが削除されたときに関連するfoodstuffも削除される' do
      foodstuff = FactoryBot.create(:foodstuff, user: user)
      expect { user.destroy }.to change { Foodstuff.count }.by(-1)
    end

    it 'foodstuffが削除されたときに関連するcommentsも削除される' do
      foodstuff = FactoryBot.create(:foodstuff, user: user)
      comment = FactoryBot.create(:comment, user: user, commentable: foodstuff)
      expect { foodstuff.destroy }.to change { Comment.count }.by(-1)
    end

    it 'foodstuffが削除されたときに関連するuser_actionsも削除される' do
      foodstuff = FactoryBot.create(:foodstuff, user: user)
      user_action = FactoryBot.create(:user_action, user: user, actionable: foodstuff)
      expect { foodstuff.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index(:user_id) }
  end
end
