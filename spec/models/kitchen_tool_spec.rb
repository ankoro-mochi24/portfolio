require 'rails_helper'

RSpec.describe KitchenTool, type: :model do
  # バリデーションのテスト
  it "名前があれば有効である" do
    kitchen_tool = KitchenTool.new(name: "フライパン")
    expect(kitchen_tool).to be_valid
  end

  it "名前がない場合は無効である" do
    kitchen_tool = KitchenTool.new(name: nil)
    expect(kitchen_tool).not_to be_valid
  end

  # アソシエーションのテスト
  it { should have_many(:recipe_kitchen_tools) }
  it { should have_many(:recipes).through(:recipe_kitchen_tools) }
  it { should have_many(:user_kitchen_tools) }
  it { should have_many(:users).through(:user_kitchen_tools) }
end
