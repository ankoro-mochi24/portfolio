require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、ユーザーは有効である' do
      expect(user).to be_valid
    end

    it '名前がなければ無効であること' do
      user.name = nil
      expect(user).to_not be_valid
      expect(user.errors[:name]).to include(I18n.t('activerecord.errors.models.user.attributes.name.blank'))
    end

    it 'メールアドレスがなければ無効であること' do
      user.email = nil
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.blank'))
    end

    it 'メールアドレスが重複していれば無効であること' do
      user_with_duplicate_email = FactoryBot.build(:user, email: user.email)
      expect(user_with_duplicate_email).to_not be_valid
      expect(user_with_duplicate_email.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.taken'))
    end

    it '無効なフォーマットのメールアドレスは無効であること' do
      invalid_emails = [
        'invalid_email',      # アットマークがない
        'user@domain',        # ドメインにドットがない
        'user@.com',          # ドメイン名が空
        'user@domain..com',   # ドットが連続
        'user@@domain.com',   # アットマークが2つ
        'user@domain-.com',   # ドメインがハイフンで終わる
        'user@-domain.com',   # ドメインがハイフンで始まる
        'user@domain.c',      # トップレベルドメインが1文字
        'user@do..main.com'   # ドットが途中で連続
      ]
    
      invalid_emails.each do |email|
        user.email = email
        expect(user).to_not be_valid, "#{email} は無効であるべきです"
        expect(user.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
      end
    end

    it 'パスワードが6文字以上でなければ無効であること' do
      user.password = '12345'
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6))
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it { should have_many(:foodstuffs).dependent(:destroy) }
    it { should have_many(:recipes).dependent(:destroy) }
    it { should have_many(:toppings).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:user_actions).dependent(:destroy).class_name('UserAction') }
    it { should have_many(:user_kitchen_tools).dependent(:destroy) }
    it { should have_many(:kitchen_tools).through(:user_kitchen_tools) }
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'ユーザーが削除されると関連するfoodstuffsも削除されること' do
      FactoryBot.create(:foodstuff, user: user)
      expect { user.destroy }.to change { Foodstuff.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するrecipesも削除されること' do
      FactoryBot.create(:recipe, user: user)
      expect { user.destroy }.to change { Recipe.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するcommentsも削除されること' do
      FactoryBot.create(:comment, user: user)
      expect { user.destroy }.to change { Comment.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するuser_actionsも削除されること' do
      FactoryBot.create(:user_action, user: user)
      expect { user.destroy }.to change { UserAction.count }.by(-1)
    end

    it 'ユーザーが削除されると関連するtoppingsも削除されること' do
      FactoryBot.create(:topping, user: user)
      expect { user.destroy }.to change { Topping.count }.by(-1)
    end
  end

  # カスタムバリデーションのテスト
  describe 'カスタムバリデーションのテスト' do
    it '「good」と「bad」のアクションが同時に存在できないこと' do
      recipe = FactoryBot.create(:recipe, user: user)
      FactoryBot.create(:user_action, user: user, actionable: recipe, action_type: 'good')

      conflicting_action = FactoryBot.build(:user_action, user: user, actionable: recipe, action_type: 'bad')
      expect(conflicting_action).to_not be_valid
      expect(conflicting_action.errors[:base]).to include(I18n.t('activerecord.errors.models.user_action.messages.good_bad_conflict'))
    end
  end

  # ネストされた属性のテスト
  describe 'ネストされた属性のテスト' do
    it 'ユーザーが持っている調理器具の追加と削除ができること' do
      kitchen_tool = FactoryBot.create(:kitchen_tool)
      user_with_tool = FactoryBot.create(:user, user_kitchen_tools_attributes: [{ kitchen_tool_name: kitchen_tool.name }])

      # 追加の確認
      expect(user_with_tool.kitchen_tools).to include(kitchen_tool)

      # 削除の確認
      user_with_tool.update(user_kitchen_tools_attributes: [{ id: user_with_tool.user_kitchen_tools.first.id, _destroy: '1' }])
      expect(user_with_tool.kitchen_tools).to be_empty
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { should have_db_index(:email).unique(true) }
    it { should have_db_index(:reset_password_token).unique(true) }
  end
end
