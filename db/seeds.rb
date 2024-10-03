require 'faker'

# ユーザーのサンプルデータを作成（ユーザーがいない場合のため）
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

=begin
=end
puts "サンプルデータの作成が完了しました！"
