require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  describe 'バリデーションのテスト' do
    it '有効なユーザーであること' do
      expect(user).to be_valid
    end

    it '名前がなければ無効であること' do
      user.name = nil
      expect(user).to_not be_valid
      expect(user.errors[:name]).to include('ユーザー名を入力してください')
    end

    it 'メールアドレスがなければ無効であること' do
      user.email = nil
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('メールアドレスを入力してください')
    end

    it 'メールアドレスが重複していれば無効であること' do
      FactoryBot.create(:user, email: 'test@example.com')
      user.email = 'test@example.com'
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('このメールアドレスはすでに使用されています')
    end

    it 'パスワードが6文字以上でなければ無効であること' do
      user.password = '12345'
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('パスワードは6文字以上で入力してください')
    end
  end

  describe 'アソシエーションのテスト' do
    it 'ユーザーが削除されると関連するレシピも削除されること' do
      user_with_recipe = FactoryBot.create(:user_with_recipes)
      expect { user_with_recipe.destroy }.to change { Recipe.count }.by(-user_with_recipe.recipes.count)
    end

    it 'ユーザーが削除されると関連する食品も削除されること' do
      user = FactoryBot.create(:user)
      foodstuff = FactoryBot.create(:foodstuff, user: user)
      expect { user.destroy }.to change { Foodstuff.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するコメントも削除されること' do
      user = FactoryBot.create(:user)
      recipe = FactoryBot.create(:recipe, user: user)
      comment = FactoryBot.create(:comment, user: user, commentable: recipe)
      expect { user.destroy }.to change { Comment.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するアクションも削除されること' do
      user = FactoryBot.create(:user)
      recipe = FactoryBot.create(:recipe, user: user)
      user_action = FactoryBot.create(:user_action, user: user, actionable: recipe)
      expect { user.destroy }.to change { UserAction.count }.by(-1)
    end
  end

  describe 'カスタムバリデーションのテスト' do
    it '「good」と「bad」のアクションが両立しないこと' do
      user = FactoryBot.create(:user)
      recipe = FactoryBot.create(:recipe, user: user)

      # 最初に "good" アクションを作成
      user_action_good = FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')

      # "bad" アクションを作成しようとすると無効であることを確認
      user_action_bad = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'bad')
      expect(user_action_bad).to_not be_valid

      # エラーメッセージを英語のままテスト
      expect(user_action_bad.errors[:base]).to include('Cannot have both good and bad actions at the same time')
    end
  end

  describe 'ネストされた属性のテスト' do
    it 'ユーザーが持っている調理器具の追加・削除ができること' do
      kitchen_tool = FactoryBot.create(:kitchen_tool)
      user_with_tool = FactoryBot.create(:user, user_kitchen_tools_attributes: [{ kitchen_tool_name: kitchen_tool.name }])

      # 追加されたか確認
      expect(user_with_tool.kitchen_tools).to include(kitchen_tool)

      # 削除ができるか確認
      user_with_tool.update(user_kitchen_tools_attributes: [{ id: user_with_tool.user_kitchen_tools.first.id, _destroy: '1' }])
      expect(user_with_tool.kitchen_tools).to be_empty
    end
  end
end
