require 'rails_helper'

RSpec.describe "Foodstuffs", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:foodstuff) { create(:foodstuff, user: user, name: "Sample Foodstuff", price: 1000, link: "http://example.com") }

  before do
    sign_in user
  end

  describe "GET /foodstuffs" do
    it "食品一覧が表示されること" do
      get foodstuffs_view_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("foodstuffs.index.title"))
    end
  end

  describe "GET /foodstuffs/:id" do
    context "食品が存在する場合" do
      it "食品の詳細が表示されること" do
        get foodstuff_path(foodstuff)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Sample Foodstuff")
      end
    end

    context "食品が存在しない場合" do
      it "エラーメッセージが表示されること" do
        expect {
          get foodstuff_path(id: 9999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /foodstuffs" do
    context "有効なパラメータの場合" do
      it "食品が作成され、成功メッセージが表示されること" do
        image_path = Rails.root.join("spec", "fixtures", "sample.jpg")
        image = Rack::Test::UploadedFile.new(image_path, "image/jpeg")

        expect {
          post foodstuffs_path, params: { foodstuff: { name: "New Foodstuff", price: 1500, link: "http://newlink.com", image: [image] } }
        }.to change(Foodstuff, :count).by(1)

        expect(response).to redirect_to(Foodstuff.last)
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.foodstuff_created"))
      end
    end

    context "無効なパラメータの場合" do
      it "食品が作成されず、エラーメッセージが表示されること" do
        expect {
          post foodstuffs_path, params: { foodstuff: { name: "", price: -100, link: "", image: nil } }
        }.not_to change(Foodstuff, :count)

        expect(response.body).to include(I18n.t("activerecord.errors.models.foodstuff.attributes.name.blank"))
        expect(response.body).to include(I18n.t("activerecord.errors.models.foodstuff.attributes.price.greater_than_or_equal_to"))
        expect(response.body).to include(I18n.t("activerecord.errors.models.foodstuff.attributes.link.blank"))
        expect(response.body).to include(I18n.t("activerecord.errors.models.foodstuff.attributes.image.blank"))
      end
    end
  end

  describe "PATCH /foodstuffs/:id" do
    context "ユーザーが自身の食品を更新する場合" do
      it "食品が更新され、成功メッセージが表示されること" do
        patch foodstuff_path(foodstuff), params: { foodstuff: { name: "Updated Foodstuff" } }

        expect(response).to redirect_to(foodstuff_path(foodstuff))
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.foodstuff_updated"))
        expect(foodstuff.reload.name).to eq("Updated Foodstuff")
      end
    end

    context "無効なパラメータで更新した場合" do
      it "食品が更新されず、エラーメッセージが表示されること" do
        patch foodstuff_path(foodstuff), params: { foodstuff: { price: -500 } }

        expect(response.body).to include(I18n.t("activerecord.errors.models.foodstuff.attributes.price.greater_than_or_equal_to"))
        expect(foodstuff.reload.price).to eq(1000)
      end
    end
  end

  describe "DELETE /foodstuffs/:id" do
    context "ユーザーが自身の食品を削除する場合" do
      it "食品が削除され、成功メッセージが表示されること" do
        expect {
          delete foodstuff_path(foodstuff)
        }.to change(Foodstuff, :count).by(-1)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include(I18n.t("notices.foodstuff_deleted"))
      end
    end

    context "他のユーザーの食品を削除しようとした場合" do
      before do
        sign_out user
        sign_in other_user
      end

      it "削除が許可されず、エラーメッセージが表示されること" do
        delete foodstuff_path(foodstuff)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include(I18n.t('errors.messages.unauthorized_foodstuff'))
      end
    end
  end
end
