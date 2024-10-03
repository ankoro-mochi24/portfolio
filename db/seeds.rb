require 'faker'

sample_image_url = ["https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"]

# データをシード
User.find_each do |user|
  5.times do
    begin
      Foodstuff.create!(
        name: Faker::Food.ingredient,
        price: Faker::Commerce.price(range: 100..1000),
        description: Faker::Food.description,
        link: Faker::Internet.url,
        image: sample_image_url,  # 配列として渡す
        user: user
      )
    rescue ActiveRecord::RecordInvalid => e
      puts "Error creating foodstuff: #{e.record.errors.full_messages}"
    end
  end
end

=begin
10.times do
  User.create!(
    name: Faker::Name.name,                  # ランダムな名前を生成
    email: Faker::Internet.unique.email,      # ランダムな一意のメールアドレスを生成
    password: 'password',                     # デフォルトのパスワードを設定
    password_confirmation: 'password',        # パスワード確認
    created_at: Faker::Date.between(from: 2.years.ago, to: Date.today),  # 過去2年間でランダムな作成日
    updated_at: Faker::Date.between(from: 2.years.ago, to: Date.today)   # 過去2年間でランダムな更新日
  )
end
=end
puts "サンプルデータの作成が完了しました！"
