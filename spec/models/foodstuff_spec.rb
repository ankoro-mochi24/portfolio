require 'rails_helper'

RSpec.describe Foodstuff, type: :model do
  let(:user) { create(:user) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、有効である' do
      foodstuff = build(:foodstuff, user:)
      expect(foodstuff).to be_valid
    end

    it 'nameがない場合、無効である' do
      foodstuff = build(:foodstuff, name: nil, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:name]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.name.blank'))
    end

    it 'priceがない場合、無効である' do
      foodstuff = build(:foodstuff, price: nil, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.price.blank'))
    end

    it 'priceが負の値の場合、無効である' do
      foodstuff = build(:foodstuff, price: -1, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.price.greater_than_or_equal_to'))
    end

    it 'priceが整数でない場合、無効である' do
      foodstuff = build(:foodstuff, price: 10.5, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:price]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.price.not_an_integer'))
    end

    it 'linkがない場合、無効である' do
      foodstuff = build(:foodstuff, link: nil, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:link]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.link.blank'))
    end

    it 'imageがない場合、無効である' do
      foodstuff = build(:foodstuff, image: nil, user:)
      expect(foodstuff).not_to be_valid
      expect(foodstuff.errors[:image]).to include(I18n.t('activerecord.errors.models.foodstuff.attributes.image.blank'))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:user_actions).dependent(:destroy) }
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'foodstuffが削除されたときに関連するcommentsも削除される' do
      foodstuff = create(:foodstuff, user:)
      create(:comment, user:, commentable: foodstuff)
      expect { foodstuff.destroy }.to change(Comment, :count).by(-1)
    end

    it 'foodstuffが削除されたときに関連するuser_actionsも削除される' do
      foodstuff = create(:foodstuff, user:)
      create(:user_action, user:, actionable: foodstuff)
      expect { foodstuff.destroy }.to change(UserAction, :count).by(-1)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index(:user_id) }
  end
end
