# spec/models/topping_spec.rb
require 'rails_helper'

RSpec.describe Topping, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }
  
  describe 'バリデーションのテスト' do
    subject { topping.valid? }
    let(:topping) { FactoryBot.build(:topping, name: topping_name, user: user, recipe: recipe) }

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
      before { FactoryBot.create(:topping, name: 'ネギ', user: user, recipe: recipe) }
      let(:topping_name) { 'ネギ' }
      
      it '無効であり、エラーメッセージが正しいこと' do
        topping.valid?
        expect(topping.errors[:name]).to include(I18n.t('activerecord.errors.models.topping.attributes.name.taken', value: 'ネギ'))
      end
    end
  end

  describe '削除時のテスト' do
    it 'toppingが削除されたときに関連するuser_actionsも削除される' do
      topping = FactoryBot.create(:topping, user: user, recipe: recipe)
      FactoryBot.create(:user_action, user: user, actionable: topping)

      expect { topping.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  describe 'アソシエーションのテスト' do
    it { should belong_to(:recipe) }
    it { should belong_to(:user) }
    it { should have_many(:user_actions).dependent(:destroy) }
  end
end
