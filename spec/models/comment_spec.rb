require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) { FactoryBot.create(:recipe, user: user) }

  describe 'バリデーションのテスト' do
    it "bodyがあり、userおよびcommentableが関連付けられている場合、有効である" do
      comment = Comment.new(body: "これはテストコメントです。", user: user, commentable: recipe)
      expect(comment).to be_valid
    end

    it "bodyがない場合は無効である" do
      comment = Comment.new(body: nil, user: user, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.blank'))
    end

    it "bodyが最小文字数未満の場合は無効である" do
      comment = Comment.new(body: "", user: user, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.too_short', count: 1))
    end

    it "bodyが最大文字数を超える場合は無効である" do
      long_body = "あ" * 401
      comment = Comment.new(body: long_body, user: user, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include(I18n.t('errors.messages.too_long', count: 400))
    end

    it "userがない場合は無効である" do
      comment = Comment.new(body: "これはテストコメントです。", user: nil, commentable: recipe)
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to include(I18n.t('errors.messages.required'))
    end

    it "commentableがない場合は無効である" do
      comment = Comment.new(body: "これはテストコメントです。", user: user, commentable: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:commentable]).to include(I18n.t('errors.messages.required'))
    end
  end

  describe 'アソシエーションのテスト' do
    it { should belong_to(:user) }
    it 'commentableがポリモーフィック関連であることを確認する' do
      expect(Comment.reflect_on_association(:commentable).options[:polymorphic]).to be_truthy
    end

    it 'commentableがRecipeモデルと関連付けられることを確認する' do
      comment = Comment.new(body: "テストコメント", user: user, commentable: recipe)
      expect(comment).to be_valid
      expect(comment.commentable).to be_a(Recipe)
    end
  
    it 'commentableがFoodstuffモデルと関連付けられることを確認する' do
      foodstuff = FactoryBot.create(:foodstuff)
      comment = Comment.new(body: "テストコメント", user: user, commentable: foodstuff)
      expect(comment).to be_valid
      expect(comment.commentable).to be_a(Foodstuff)
    end
  end

  describe '削除時のテスト' do
    it "userが削除されたときにコメントも削除される" do
      comment = FactoryBot.create(:comment, user: user, commentable: recipe)
      expect { user.destroy }.to change { Comment.count }.by(-1)
    end

    it "commentableがRecipeモデルのインスタンスである場合、Recipeが削除されるとコメントも削除される" do
      comment = FactoryBot.create(:comment, user: user, commentable: recipe)
      expect { recipe.destroy }.to change { Comment.count }.by(-1)
    end
    
    it "commentableがFoodstuffモデルのインスタンスである場合、Foodstuffが削除されるとコメントも削除される" do
      foodstuff = FactoryBot.create(:foodstuff)
      comment = FactoryBot.create(:comment, user: user, commentable: foodstuff)
      expect { foodstuff.destroy }.to change { Comment.count }.by(-1)
    end
  end

  describe 'データベースインデックスのテスト' do
    it { should have_db_index([:commentable_type, :commentable_id]) }
    it { should have_db_index(:user_id) }
  end
end
