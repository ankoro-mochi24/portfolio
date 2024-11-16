require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user:) }

  describe 'バリデーションのテスト' do
    it "bodyがあり、userおよびcommentableが関連付けられている場合、有効である" do
      comment = described_class.new(body: "これはテストコメントです。", user:, commentable: recipe)
      expect(comment).to be_valid
    end

    it "bodyがない場合は無効である" do
      comment = described_class.new(body: nil, user:, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.blank'))
    end

    it "bodyが最小文字数未満の場合は無効である" do
      comment = described_class.new(body: "", user:, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.too_short', count: 1))
    end

    it "bodyが最大文字数を超える場合は無効である" do
      long_body = "あ" * 401
      comment = described_class.new(body: long_body, user:, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.too_long', count: 400))
    end

    it "userがない場合は無効である" do
      comment = described_class.new(body: "これはテストコメントです。", user: nil, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to include(I18n.t('errors.messages.required'))
    end

    it "commentableがない場合は無効である" do
      comment = described_class.new(body: "これはテストコメントです。", user:, commentable: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:commentable]).to include(I18n.t('errors.messages.required'))
    end
  end

  describe 'アソシエーションのテスト' do
    it { is_expected.to belong_to(:user) }

    it 'commentableがポリモーフィック関連であることを確認する' do
      expect(described_class.reflect_on_association(:commentable).options[:polymorphic]).to be_truthy
    end

    it 'commentableがRecipeモデルと関連付けられることを確認する' do
      comment = described_class.new(body: "テストコメント", user:, commentable: recipe)
      expect(comment).to be_valid
      expect(comment.commentable).to be_a(Recipe)
    end

    it 'commentableがFoodstuffモデルと関連付けられることを確認する' do
      foodstuff = FactoryBot.create(:foodstuff)
      comment = described_class.new(body: "テストコメント", user:, commentable: foodstuff)
      expect(comment).to be_valid
      expect(comment.commentable).to be_a(Foodstuff)
    end
  end

  describe '削除時のテスト' do
    it "userが削除されたときにコメントも削除される" do
      FactoryBot.create(:comment, user:, commentable: recipe)
      expect { user.destroy }.to change(described_class, :count).by(-1)
    end

    it "commentableがRecipeモデルのインスタンスである場合、Recipeが削除されるとコメントも削除される" do
      FactoryBot.create(:comment, user:, commentable: recipe)
      expect { recipe.destroy }.to change(described_class, :count).by(-1)
    end

    it "commentableがFoodstuffモデルのインスタンスである場合、Foodstuffが削除されるとコメントも削除される" do
      foodstuff = FactoryBot.create(:foodstuff)
      FactoryBot.create(:comment, user:, commentable: foodstuff)
      expect { foodstuff.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index([:commentable_type, :commentable_id]) }
    it { is_expected.to have_db_index(:user_id) }
  end
end
