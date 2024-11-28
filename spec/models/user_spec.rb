require 'rails_helper'

RSpec.describe User, type: :model do
  # 有効なデフォルト値を持つユーザーの作成
  let(:user) { create(:user, name: 'Valid Name', email: 'test@example.com', password: 'password1') }

  # バリデーションのテスト
  describe 'バリデーションのテスト' do
    it 'すべての属性が有効である場合、ユーザーは有効である' do
      expect(user).to be_valid
    end

    it '名前がなければ無効であること' do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include(I18n.t('activerecord.errors.models.user.attributes.name.blank'))
    end

    it '名前が50文字を超える場合、無効であること' do
      user.name = 'a' * 51
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include(I18n.t('errors.messages.too_long', count: 50))
    end

    it '有効なフォーマットのメールアドレスは有効であること' do
      valid_emails = ['test@example.com', 'user.name@domain.co.jp', 'name+tag@domain.org']
      valid_emails.each do |email|
        user.email = email
        expect(user).to be_valid, "#{email} は有効であるべきです"
      end
    end

    it 'メールアドレスがなければ無効であること' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.blank'))
    end

    it 'メールアドレスが重複していれば無効であること' do
      user_with_duplicate_email = build(:user, email: user.email)
      expect(user_with_duplicate_email).not_to be_valid
      expect(user_with_duplicate_email.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.taken'))
    end

    it '無効なフォーマットのメールアドレスは無効であること' do
      invalid_emails = [
        'invalid_email', 'user@domain', 'user@.com',
        'user@domain..com', 'user@@domain.com', 'user@domain-.com',
        'user@-domain.com', 'user@domain.c', 'user@do..main.com'
      ]
      invalid_emails.each do |email|
        user.email = email
        expect(user).not_to be_valid, "#{email} は無効であるべきです"
        expect(user.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
      end
    end
  end

  describe 'パスワード変更のバリデーション' do
    it 'パスワードが入力されていない場合は変更されないこと' do
      user.password = nil
      expect(user).to be_valid
    end

    it 'パスワードが6文字以上でなければ無効であること' do
      user.password = '12345'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6))
    end

    it 'パスワードが英字を含まない場合、無効であること' do
      user.password = '123456'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.weak'))
    end

    it 'パスワードが数字を含まない場合、無効であること' do
      user.password = 'password'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.weak'))
    end

    it '有効なパスワードは正しく更新されること' do
      user.password = 'Valid1'
      expect(user).to be_valid
    end
  end

  # アソシエーションのテスト
  describe 'アソシエーションのテスト' do
    it { is_expected.to have_many(:foodstuffs).dependent(:destroy) }
    it { is_expected.to have_many(:recipes).dependent(:destroy) }
    it { is_expected.to have_many(:toppings).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:user_actions).dependent(:destroy).class_name('UserAction') }
    it { is_expected.to have_many(:user_kitchen_tools).dependent(:destroy) }
    it { is_expected.to have_many(:kitchen_tools).through(:user_kitchen_tools) }
  end

  # 削除時のテスト
  describe '削除時のテスト' do
    it 'ユーザーが削除されると関連するfoodstuffsも削除されること' do
      create(:foodstuff, user:)
      expect { user.destroy }.to change(Foodstuff, :count).by(-1)
    end

    it 'ユーザーが削除されると関連するrecipesも削除されること' do
      create(:recipe, user:)
      expect { user.destroy }.to change(Recipe, :count).by(-1)
    end

    it 'ユーザーが削除されると関連するcommentsも削除されること' do
      recipe = create(:recipe, user:)
      create(:comment, user:, commentable: recipe) # recipeをcommentableに指定
      expect { user.destroy }.to change(Comment, :count).by(-1)
    end

    it 'ユーザーが削除されると関連するuser_actionsも削除されること' do
      recipe = create(:recipe, user:)
      create(:user_action, user:, actionable: recipe) # recipeをactionableに指定
      expect { user.destroy }.to change(UserAction, :count).by(-1)
    end

    it 'ユーザーが削除されると関連するtoppingsも削除されること' do
      recipe = create(:recipe, user:)
      create(:topping, user:, recipe:)
      expect { user.destroy }.to change(Topping, :count).by(-1)
    end
  end

  # ネストされた属性のテスト
  describe 'ネストされた属性のテスト' do
    it 'ユーザーが持っている調理器具の追加と削除ができること' do
      kitchen_tool = create(:kitchen_tool)

      user_with_tool = build(
        :user,
        user_kitchen_tools_attributes: [
          { kitchen_tool_id: kitchen_tool.id, kitchen_tool_name: kitchen_tool.name }
        ]
      )

      expect(user_with_tool.save).to be true
      expect(user_with_tool.kitchen_tools).to include(kitchen_tool)
    end
  end

  # データベースインデックスのテスト
  describe 'データベースインデックスのテスト' do
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
  end
end
