# spec/models/topping_spec.rb
require 'rails_helper'

RSpec.describe Topping, type: :model do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user:) }

  describe 'バリデーションのテスト' do
    subject { topping.valid? }

    let(:topping) { build(:topping, name: topping_name, user:, recipe:) }

    context 'すべての属性が有効な場合' do
      let(:topping_name) { 'ネギ' }

      it '有効である' do
        expect(topping).to be_valid
      end
    end

    context 'nameがない場合' do
      let(:topping_name) { nil }

      it '無効であり、エラーメッセージが正しいこと' do
        topping.valid?
        expect(topping.errors[:name]).to include(I18n.t('errors.messages.blank'))
      end
    end

    context '同じレシピに同じnameが存在する場合' do
      before { create(:topping, name: 'ネギ', user:, recipe:) }

      let(:topping_name) { 'ネギ' }

      it '無効であり、エラーメッセージが正しいこと' do
        topping.valid?
        expect(topping.errors[:name]).to include(I18n.t('activerecord.errors.models.topping.attributes.name.taken', value: 'ネギ'))
      end
    end
  end

  describe '削除時のテスト' do
    it 'toppingが削除されたときに関連するuser_actionsも削除される' do
      topping = create(:topping, user:, recipe:)
      create(:user_action, user:, actionable: topping)

      expect { topping.destroy }.to change(UserAction, :count).by(-1)
    end
  end

  describe 'アソシエーションのテスト' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:user_actions).dependent(:destroy) }
  end
end
