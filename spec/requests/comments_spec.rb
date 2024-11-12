require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }
  let!(:comment) { create(:comment, commentable: recipe, user: user, body: "元のコメント") }

  before do
    sign_in user
  end

  describe "POST /comments" do
    context "有効なパラメータの場合" do
      it "コメントが作成され、成功メッセージが表示されること" do
        expect {
          post recipe_comments_path(recipe), params: { comment: { body: "新しいコメント" }, commentable_type: "Recipe", commentable_id: recipe.id }
        }.to change(Comment, :count).by(1)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("コメントが追加されました。")
      end
    end

    context "無効なパラメータの場合" do
      it "コメントが作成されず、エラーメッセージが表示されること" do
        expect {
          post recipe_comments_path(recipe), params: { comment: { body: "" }, commentable_type: "Recipe", commentable_id: recipe.id }
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("コメントの追加に失敗しました。")
      end
    end
  end

  describe "PATCH /comments/:id" do
    context "ユーザーが自身のコメントを更新する場合" do
      it "コメントが更新され、成功メッセージが表示されること" do
        patch recipe_comment_path(recipe, comment), params: { comment: { body: "更新されたコメント" } }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("コメントが更新されました。")
        expect(comment.reload.body).to eq("更新されたコメント")
      end
    end

    context "無効なパラメータで更新した場合" do
      it "コメントが更新されず、エラーメッセージが表示されること" do
        patch recipe_comment_path(recipe, comment), params: { comment: { body: "" } }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("コメントの更新に失敗しました。")
        expect(comment.reload.body).to eq("元のコメント")
      end
    end

    context "他のユーザーのコメントを更新しようとした場合" do
      before do
        sign_out user
        sign_in other_user
      end

      it "編集が許可されず、エラーメッセージが表示されること" do
        patch recipe_comment_path(recipe, comment), params: { comment: { body: "不正な更新" } }

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("他のユーザーのコメントを編集・削除することはできません。")
        expect(comment.reload.body).to eq("元のコメント")
      end
    end
  end

  describe "DELETE /comments/:id" do
    context "ユーザーが自身のコメントを削除する場合" do
      it "コメントが削除され、成功メッセージが表示されること" do
        expect {
          delete recipe_comment_path(recipe, comment)
        }.to change(Comment, :count).by(-1)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("コメントが削除されました。")
      end
    end

    context "他のユーザーのコメントを削除しようとした場合" do
      before do
        sign_out user
        sign_in other_user
      end

      it "削除が許可されず、エラーメッセージが表示されること" do
        expect {
          delete recipe_comment_path(recipe, comment)
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("他のユーザーのコメントを編集・削除することはできません。")
      end
    end
  end
end
