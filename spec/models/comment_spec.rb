require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user:) }
  let(:foodstuff) { create(:foodstuff) }

  describe 'バリデーションのテスト' do
    let(:comment) { described_class.new(body:, user:, commentable: recipe) }

    shared_examples '無効な場合' do |error_message|
      it '無効であること' do
        expect(comment).not_to be_valid
      end

      it 'エラーメッセージが含まれること' do
        comment.valid?
        expect(comment.errors[:body]).to include(error_message)
      end
    end

    context '有効な場合' do
      let(:body) { 'これはテストコメントです。' }

      it '有効であること' do
        expect(comment).to be_valid
      end
    end

    context 'bodyが空の場合' do
      let(:body) { nil }

      include_examples '無効な場合', I18n.t('errors.messages.blank')
    end

    context 'bodyが最小文字数未満の場合' do
      let(:body) { '' }

      include_examples '無効な場合', I18n.t('errors.messages.too_short', count: 1)
    end

    context 'bodyが最大文字数を超える場合' do
      let(:body) { 'あ' * 401 }

      include_examples '無効な場合', I18n.t('errors.messages.too_long', count: 400)
    end

    context 'userがない場合' do
      let(:body) { 'これはテストコメントです。' }

      it '無効であること' do
        comment.user = nil
        expect(comment).not_to be_valid
      end
    end

    context 'commentableがない場合' do
      let(:body) { 'これはテストコメントです。' }

      it '無効であること' do
        comment.commentable = nil
        expect(comment).not_to be_valid
      end
    end
  end

  describe 'アソシエーションのテスト' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_db_index([:commentable_type, :commentable_id]) }
    it { is_expected.to have_db_index(:user_id) }

    describe 'commentableのポリモーフィック関連' do
      it 'ポリモーフィック関連であること' do
        expect(described_class.reflect_on_association(:commentable).options[:polymorphic]).to be_truthy
      end

      it 'Recipeモデルとの関連付けが有効であること' do
        comment = described_class.new(body: 'テストコメント', user:, commentable: recipe)
        expect(comment.commentable).to be_a(Recipe)
      end

      it 'Foodstuffモデルとの関連付けが有効であること' do
        comment = described_class.new(body: 'テストコメント', user:, commentable: foodstuff)
        expect(comment.commentable).to be_a(Foodstuff)
      end
    end
  end

  describe '削除時のテスト' do
    it 'userが削除されたときにコメントも削除される' do
      create(:comment, user:, commentable: recipe)
      expect { user.destroy }.to change(described_class, :count).by(-1)
    end

    it 'Recipeが削除されたときにコメントも削除される' do
      create(:comment, user:, commentable: recipe)
      expect { recipe.destroy }.to change(described_class, :count).by(-1)
    end

    it 'Foodstuffが削除されたときにコメントも削除される' do
      create(:comment, user:, commentable: foodstuff)
      expect { foodstuff.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
