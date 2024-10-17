require 'rails_helper'

RSpec.describe ProfilesController, type: :request do
  let(:user) { create(:user) }
  let(:kitchen_tool1) { create(:kitchen_tool) }
  let(:kitchen_tool2) { create(:kitchen_tool) }

  before do
    sign_in user
  end

  describe "GET /profile/edit" do
    context "user_kitchen_toolsが空の場合" do
      it "調理器具を入力しなければ新しいレコードは作成されない" do
        expect(user.user_kitchen_tools).to be_empty

        get edit_profile_path

        expect(response).to have_http_status(:ok)
        expect(user.reload.user_kitchen_tools.size).to eq(0)  # レコードは作成されない
      end

      it "調理器具を入力して保存すれば新しいレコードが作成される" do
        expect(user.user_kitchen_tools).to be_empty

        patch profile_path, params: { user: { user_kitchen_tools_attributes: [{ kitchen_tool_id: kitchen_tool1.id }] } }

        expect(response).to redirect_to(profile_path)
        expect(user.reload.user_kitchen_tools.size).to eq(1)  # レコードが作成される
      end
    end

    context "user_kitchen_toolsを既に持っている場合" do
      before do
        user.user_kitchen_tools.create(kitchen_tool_id: kitchen_tool1.id)
      end

      it "既存のレコードが保持され、新しいレコードが追加される" do
        patch profile_path, params: { user: { 
          user_kitchen_tools_attributes: [
            { kitchen_tool_id: kitchen_tool2.id }  # 新しいレコード追加
          ] 
        }}

        expect(response).to redirect_to(profile_path)
        expect(user.reload.user_kitchen_tools.size).to eq(2)  # 既存レコードと新しいレコードが共存する
      end

      it "既存の調理器具を削除できる" do
        patch profile_path, params: { user: { user_kitchen_tools_attributes: [{ id: user.user_kitchen_tools.first.id, _destroy: '1' }] } }

        expect(response).to redirect_to(profile_path)
        expect(user.reload.user_kitchen_tools.size).to eq(0)  # 既存のレコードが削除される
      end

      it "既存の調理器具を削除しつつ、新しい調理器具を追加できる" do
        patch profile_path, params: { user: { 
          user_kitchen_tools_attributes: [
            { id: user.user_kitchen_tools.first.id, _destroy: '1' },  # 既存のレコード削除
            { kitchen_tool_id: kitchen_tool2.id }  # 新しいレコード追加
          ] 
        }}

        # レスポンスのチェック
        expect(response).to redirect_to(profile_path)
        
        # ユーザーの持つ調理器具の数を確認
        expect(user.reload.user_kitchen_tools.size).to eq(1)

        # 新しく追加されたレコードがkitchen_tool2に対応していることを確認
        expect(user.user_kitchen_tools.first.kitchen_tool_id).to eq(kitchen_tool2.id)
      end
    end
  end
end
