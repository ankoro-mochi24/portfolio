require 'faker'

30.times do
  Foodstuff.create!(
    name: Faker::Food.ingredient, # ランダムな食品名を生成
    price: Faker::Commerce.price(range: 1.0..100.0), # ランダムな価格を生成
    description: Faker::Food.description, # ランダムな説明文を生成
    link: Faker::Internet.url, # ランダムなURLを生成
    user: user, # 作成したユーザーをランダムに割り当てる
    image: Rails.root.join("app/assets/images/sample_food.jpg").open # サンプル画像を利用（Heroku環境に画像をアップロード済みと仮定）
  )
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
