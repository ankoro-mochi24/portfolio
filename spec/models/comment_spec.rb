require 'rails_helper'

RSpec.describe Comment, type: :model do
  # バリデーションのテスト
  it "bodyがあり、userおよびcommentableが関連付けられている場合、有効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)  # CommentableはRecipeにしてテスト
    comment = Comment.new(body: "コメントです", user: user, commentable: recipe)
    expect(comment).to be_valid
  end

  it "bodyがない場合は無効である" do
    user = FactoryBot.create(:user)
    recipe = FactoryBot.create(:recipe, user: user)
    comment = Comment.new(body: nil, user: user, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "userがない場合は無効である" do
    recipe = FactoryBot.create(:recipe)
    comment = Comment.new(body: "コメントです", user: nil, commentable: recipe)
    expect(comment).not_to be_valid
  end

  it "commentableがない場合は無効である" do
    user = FactoryBot.create(:user)
    comment = Comment.new(body: "コメントです", user: user, commentable: nil)
    expect(comment).not_to be_valid
  end

  # アソシエーションのテスト
  it { should belong_to(:user) }
  it { should belong_to(:commentable) }
end
