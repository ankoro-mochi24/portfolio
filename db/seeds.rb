require 'faker'

# サンプル画像のURL
sample_dish_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"
sample_step_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"

# ユーザーが存在する場合、関連要素を生成
User.find_each do |user|
  # まず材料、調理器具を生成
  ingredients = []
  kitchen_tools = []

  # 材料を10種類生成
  10.times do
    ingredients << Ingredient.find_or_create_by!(name: Faker::Food.ingredient)
  end

  # 調理器具を5種類生成
  5.times do
    kitchen_tools << KitchenTool.find_or_create_by!(name: Faker::Appliance.equipment)
  end

  # レシピを作成
  3.times do
    begin
      # レシピを作成
      recipe = Recipe.create!(
        title: Faker::Food.dish,
        dish_image: sample_dish_image_url, # サンプル画像URL
        user: user
      )

      # 材料をレシピに追加
      ingredients.sample(5).each do |ingredient|
        RecipeIngredient.create!(
          recipe: recipe,
          ingredient: ingredient,
          ingredient_name: ingredient.name
        )
      end

      # 調理器具をレシピに追加
      kitchen_tools.sample(3).each do |kitchen_tool|
        RecipeKitchenTool.create!(
          recipe: recipe,
          kitchen_tool: kitchen_tool,
          kitchen_tool_name: kitchen_tool.name
        )
      end

      # レシピの調理手順を追加
      3.times do |step_number|
        RecipeStep.create!(
          recipe: recipe,
          text: "ステップ #{step_number + 1}: #{Faker::Food.description}",
          step_image: sample_step_image_url # サンプル画像URL
        )
      end

      puts "Successfully created recipe: #{recipe.title} for user: #{user.name}"

    rescue ActiveRecord::RecordInvalid => e
      puts "Error creating recipe: #{e.record.errors.full_messages}"
      break # 最初のエラーでループを中断
    end
  end
end

=begin
# 画像のパスを環境によって変更
if Rails.env.production?
  sample_image_url = ["https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"]
else
  sample_image_path = Rails.root.join("public", "uploads", "sample.jpg")  # ローカル環境用
end

# データをシード
User.find_each do |user|
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
    break  # エラーが発生したらループを抜ける
  end
end
=end

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
