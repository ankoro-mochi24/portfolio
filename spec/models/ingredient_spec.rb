require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  # バリデーションのテスト
  it "nameがある場合、有効である" do
    ingredient = described_class.new(name: "トマト")
    expect(ingredient).to be_valid
  end

  it "nameがない場合は無効である" do
    ingredient = described_class.new(name: nil)
    expect(ingredient).not_to be_valid
  end

  # アソシエーションのテスト
  it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
  it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }
end
