FactoryBot.define do
  factory :foodstuff do
    name { "テスト食品" }
    price { 100 }
    link { "https://example.com" }
    description { "食品のテスト説明です。" }
    user

    # 画像のテストデータ（複数画像を設定）
    image { [Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample.jpg'), 'image/jpg')] }
  end
end
