#確認中
require 'rails_helper'

RSpec.describe Comment, type: :model do
  # バリデーションのテスト
  it "bodyがあり、userおよびcommentableが関連付けられている場合、有効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)  # CommentableはRecipeにしてテスト
    comment = Comment.new(body: "これはテストコメントです。", user: user, commentable: recipe)
    expect(comment).to be_valid
  end

  it "bodyがない場合は無効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    comment = Comment.new(body: nil, user: user, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "bodyが最小文字数未満の場合は無効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    comment = Comment.new(body: "", user: user, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "bodyが最大文字数を超える場合は無効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    long_body = "あ" * 401  # 400文字を超える
    comment = Comment.new(body: long_body, user: user, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "userがない場合は無効である" do
    recipe = FactoryBot.create(:recipe)
    comment = Comment.new(body: "これはテストコメントです。", user: nil, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "commentableがない場合は無効である" do
    user = FactoryBot.create(:user)
    comment = Comment.new(body: "これはテストコメントです。", user: user, commentable: nil)
    expect(comment).not_to be_valid
  end

  # アソシエーションのテスト
  it { should belong_to(:user) }

  it "commentableがポリモーフィックであることを確認する" do
    comment = Comment.reflect_on_association(:commentable)
    expect(comment.options[:polymorphic]).to be_truthy
  end

  # 削除時のテスト
  it "userが削除されたときにコメントも削除される" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    comment = FactoryBot.create(:comment, user: user, commentable: recipe)
    
    expect { user.destroy }.to change { Comment.count }.by(-1)
  end

  it "commentable（例: recipe）が削除されたときにコメントも削除される" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    comment = FactoryBot.create(:comment, user: user, commentable: recipe)
    
    expect { recipe.destroy }.to change { Comment.count }.by(-1)
  end

  # データベースインデックスのテスト
  it { should have_db_index([:commentable_type, :commentable_id]) }
  it { should have_db_index(:user_id) }
end
