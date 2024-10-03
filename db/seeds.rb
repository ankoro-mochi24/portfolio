require 'faker'

# 画像のパスを環境によって変更
if Rails.env.production?
  sample_image_url = ["https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"]
else
  sample_image_path = Rails.root.join("public", "uploads", "sample.jpg")  # ローカル環境用
end

# データをシード
User.find_each do |user|
  5.times do
    begin
      foodstuff = Foodstuff.new(
        name: Faker::Food.ingredient,
        price: Faker::Commerce.price(range: 100..1000).to_i,  # 小数を整数に変換
        description: Faker::Food.description,
        link: Faker::Internet.url,
        user: user
      )
      
      # 画像の設定
      if Rails.env.production?
        foodstuff.remote_image_urls = sample_image_url  # プロダクションではS3のURLを使用（複数扱いなので配列）
      else
        foodstuff.image = [File.open(sample_image_path)]  # ローカル環境では配列でファイルを渡す
      end
      
      foodstuff.save!
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
