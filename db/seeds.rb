require 'faker'

# サンプル画像のURL
sample_dish_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"
sample_step_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"

# 材料、調理器具、ユーザーごとに必要なデータを生成
User.find_each do |user|
  # 材料の生成 (既存の材料が少ない場合のみ追加)
  ingredients = Ingredient.all.to_a
  if ingredients.count < 10
    rice = Ingredient.find_or_create_by!(name: '白米') # 必須の「白米」を最初に生成
    ingredients << rice

    (9 - ingredients.count).times do
      ingredients << Ingredient.find_or_create_by!(name: Faker::Food.ingredient)
    end
  end

  # 調理器具の生成 (5種類未満の調理器具が存在する場合のみ追加)
  kitchen_tools = KitchenTool.all.to_a
  if kitchen_tools.count < 5
    (5 - kitchen_tools.count).times do
      kitchen_tools << KitchenTool.find_or_create_by!(name: Faker::Appliance.equipment)
    end
  end

  # ユーザーごとにレシピが3件未満であれば作成
  if user.recipes.count < 3
    (3 - user.recipes.count).times do
      begin
        # レシピの作成
        recipe = Recipe.new(
          title: Faker::Food.dish,
          dish_image: sample_dish_image_url,
          user: user
        )
        recipe.save!

        # 材料の追加
        recipe.recipe_ingredients.create!(ingredient: ingredients.sample)

        # 調理器具の追加
        recipe.recipe_kitchen_tools.create!(kitchen_tool: kitchen_tools.sample)

        # 調理手順の追加
        3.times do |step_number|
          recipe.recipe_steps.create!(
            text: "ステップ #{step_number + 1}: #{Faker::Food.description}",
            step_image: sample_step_image_url
          )
        end

        # レシピにコメントがなければコメントを追加
        if recipe.comments.count < 3
          (3 - recipe.comments.count).times do
            Comment.create!(
              user: user,
              commentable: recipe,
              body: Faker::Lorem.sentence
            )
          end
        end

        # トッピングの追加
        if recipe.toppings.count < 2
          (2 - recipe.toppings.count).times do
            Topping.create!(
              user: user,
              recipe: recipe,
              name: Faker::Food.ingredient
            )
          end
        end

        # ユーザーアクションの追加
        %w[bookmark good bad].sample(2).each do |action_type|
          unless UserAction.exists?(user: user, actionable: recipe, action_type: action_type)
            UserAction.create!(
              user: user,
              actionable: recipe,
              action_type: action_type
            )
          end
        end

      rescue ActiveRecord::RecordInvalid => e
        puts "Error creating recipe or related data for user #{user.id}: #{e.message}"
      end
    end
  end
end
=begin
# サンプル画像のURL
sample_dish_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"
sample_step_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"

# ユーザーが存在する場合、関連要素を生成
User.find_each do |user|
  # まず材料、調理器具を生成
  ingredients = []
  kitchen_tools = []

  # 材料を10種類生成（必ず "白米" を追加）
  rice = Ingredient.find_or_create_by!(name: '白米') # 必須の「白米」を最初に生成
  ingredients << rice

  9.times do
    ingredients << Ingredient.find_or_create_by!(name: Faker::Food.ingredient)
  end

  # 調理器具を5種類生成
  5.times do
    kitchen_tools << KitchenTool.find_or_create_by!(name: Faker::Appliance.equipment)
  end

  # レシピを作成
  3.times do
    begin
      # レシピを作成（remote_dish_image_urlを使用して画像を設定）
      recipe = Recipe.new(
        title: Faker::Food.dish,
        remote_dish_image_url: sample_dish_image_url,  # サンプル画像URLを設定
        user: user
      )

      # 最初の材料として必ず "白米" を追加
      recipe.recipe_ingredients.build(
        ingredient: rice,
        ingredient_name: rice.name
      )

      # 残りの材料を追加（"白米" 以外のものをランダムに選択）
      ingredients.sample(4).each do |ingredient|
        next if ingredient == rice # 白米は既に追加されているのでスキップ
        recipe.recipe_ingredients.build(
          ingredient: ingredient,
          ingredient_name: ingredient.name
        )
      end

      # 調理器具をレシピに追加（必ず1つ以上追加）
      kitchen_tool = kitchen_tools.sample(1).first
      recipe.recipe_kitchen_tools.build(
        kitchen_tool: kitchen_tool,
        kitchen_tool_name: kitchen_tool.name
      )

      # レシピの調理手順を追加
      3.times do |step_number|
        recipe.recipe_steps.build(
          text: "ステップ #{step_number + 1}: #{Faker::Food.description}",
          remote_step_image_url: sample_step_image_url # サンプル画像URL
        )
      end

      # レシピを保存
      recipe.save!

    rescue ActiveRecord::RecordInvalid => e
      puts "Error creating recipe: #{e.record.errors.full_messages}"
      break # 最初のエラーでループを中断
    end
  end
end

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
