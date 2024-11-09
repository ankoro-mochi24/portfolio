require 'faker'

# サンプルデータ生成数を制限
MAX_COMMENTS = 3
MAX_ACTIONS = 5
MAX_TOPPINGS = 2
RECIPE_COUNT = 3
USER_COUNT = 10
INGREDIENT_COUNT = 10
KITCHENTOOL_COUNT = 5

# サンプルのアクションタイプ
ACTION_TYPES = %w[bookmark good bad]

# グローバル変数で生成状況をカウント
$total_created = 0
$total_skipped_good = 0
$total_skipped_bad = 0
$total_failures = 0
$total_comments = 0
$total_toppings = 0
$total_recipes = 0
$total_foodstuffs = 0

# サンプルのコメントを生成する関数
def create_comments(commentable, users)
  created_count = 0
  users.sample(MAX_COMMENTS).each do |user|
    next if Comment.exists?(user: user, commentable: commentable)

    Comment.create!(
      user: user,
      commentable: commentable,
      body: Faker::Restaurant.review
    )
    created_count += 1
  end
  $total_comments += created_count
end

# ユーザアクションを生成する関数
def create_user_actions(actionable, users)
  users.sample(MAX_ACTIONS).each do |user|
    ACTION_TYPES.sample(2).each do |action_type|
      next if UserAction.exists?(user: user, actionable: actionable, action_type: action_type)

      if action_type == 'good' && user.user_actions.exists?(actionable: actionable, action_type: 'bad')
        $total_skipped_good += 1
        next
      elsif action_type == 'bad' && user.user_actions.exists?(actionable: actionable, action_type: 'good')
        $total_skipped_bad += 1
        next
      end

      begin
        UserAction.create!(
          user: user,
          actionable: actionable,
          action_type: action_type
        )
        $total_created += 1
      rescue ActiveRecord::RecordInvalid => e
        $total_failures += 1
        puts "ユーザー #{user.id} の #{actionable.class.name} #{actionable.id} に対するアクションの作成に失敗しました: #{e.message}"
      end
    end
  end
end

# レシピにトッピングを追加する関数
def create_toppings(recipe, users)
  created_count = 0
  users.sample(MAX_TOPPINGS).each do |user|
    topping_name = Faker::Food.ingredient

    unless Topping.exists?(name: topping_name, recipe: recipe)
      Topping.create!(recipe: recipe, user: user, name: topping_name)
      created_count += 1
    end
  end
  $total_toppings += created_count
end

# 全ユーザーを取得
users = User.all

# レシピに対してコメント、ユーザアクション、トッピングを追加
Recipe.find_each do |recipe|
  create_comments(recipe, users)
  create_user_actions(recipe, users)
  create_toppings(recipe, users)
end

# 食品に対してコメントとユーザアクションを追加
Foodstuff.find_each do |foodstuff|
  create_comments(foodstuff, users)
  create_user_actions(foodstuff, users)
end

# 必要なレコード数を確認して、生成する処理
def check_and_create_records(model, count, counter_var)
  existing_count = model.count
  if existing_count >= count
    puts "#{model.name} テーブルにはすでに#{count}個以上のレコードが存在します。"
  else
    needed = count - existing_count
    yield(needed)
    counter_var += needed
  end
end

# ユーザーの作成
check_and_create_records(User, USER_COUNT, $total_created) do |needed|
  needed.times do
    User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      password_confirmation: 'password',
      created_at: Faker::Date.between(from: 2.years.ago, to: Date.today),
      updated_at: Faker::Date.between(from: 2.years.ago, to: Date.today)
    )
  end
end

# 材料と調理器具を生成
check_and_create_records(Ingredient, INGREDIENT_COUNT, $total_recipes) do |needed|
  rice = Ingredient.find_or_create_by!(name: '白米')
  ingredients = [rice]
  (needed - 1).times do
    ingredient_name = Faker::Food.ingredient
    next if Ingredient.exists?(name: ingredient_name) # 同じ材料が既に存在していないか確認
    ingredients << Ingredient.create!(name: ingredient_name)
  end
end

check_and_create_records(KitchenTool, KITCHENTOOL_COUNT, $total_recipes) do |needed|
  needed.times do
    KitchenTool.create!(name: Faker::Appliance.equipment)
  end
end

# レシピの作成
check_and_create_records(Recipe, RECIPE_COUNT, $total_recipes) do |needed|
  sample_image_path = Rails.root.join("app", "assets", "images", "sample.jpg")
  recipe_sample_image_url = "https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"  # Recipe用のサンプル画像URL

  needed.times do
    user = User.order("RANDOM()").first
    recipe = Recipe.new(
      title: Faker::Food.dish,
      user: user
    )

    # dish_image (単一ファイルアップロードの処理)
    if Rails.env.production?
      recipe.remote_dish_image_url = recipe_sample_image_url
    else
      recipe.dish_image = File.open(sample_image_path)
    end

    # 材料をレシピに追加（白米は必ず1つ、他の材料も重複を避ける）
    added_ingredients = []
    rice = Ingredient.find_by(name: '白米')
    recipe.recipe_ingredients.build(ingredient: rice, ingredient_name: rice.name)
    added_ingredients << rice.name
    Ingredient.where.not(name: '白米').sample(4).each do |ingredient|
      next if added_ingredients.include?(ingredient.name) # 重複を避ける
      recipe.recipe_ingredients.build(ingredient: ingredient, ingredient_name: ingredient.name)
      added_ingredients << ingredient.name
    end

    # 調理器具をレシピに追加
    kitchen_tool = KitchenTool.order("RANDOM()").first
    recipe.recipe_kitchen_tools.build(kitchen_tool: kitchen_tool, kitchen_tool_name: kitchen_tool.name)

    # 調理手順をレシピに追加
    3.times do |step_number|
      recipe_step = recipe.recipe_steps.build(
        text: "ステップ #{step_number + 1}: #{Faker::Food.description}"
      )

      # step_image (単一ファイルアップロードの処理)
      if Rails.env.production?
        recipe_step.remote_step_image_url = recipe_sample_image_url
      else
        recipe_step.step_image = File.open(sample_image_path)
      end
    end

    if recipe.save
      $total_recipes += 1
    else
      puts "レシピの作成に失敗しました: #{recipe.errors.full_messages.join(', ')}"
    end
  end
end

# 食品を生成
check_and_create_records(Foodstuff, USER_COUNT, $total_foodstuffs) do |needed|
  foodstuff_sample_image_url = ["https://okome-biyori-bucket.s3.ap-northeast-1.amazonaws.com/sample.jpg"]  # Foodstuff用のサンプル画像URL

  User.find_each do |user|
    foodstuff = Foodstuff.new(
      name: Faker::Food.ingredient,
      price: Faker::Commerce.price(range: 100..1000).to_i,
      description: Faker::Food.description,
      link: Faker::Internet.url,
      user: user
    )
    
    if Rails.env.production?
      foodstuff.remote_image_urls = foodstuff_sample_image_url
    else
      sample_image_path = Rails.root.join("public", "uploads", "sample.jpg")
      foodstuff.image = [File.open(sample_image_path)]
    end

    if foodstuff.save
      $total_foodstuffs += 1
    else
      puts "食品の作成に失敗しました: #{foodstuff.errors.full_messages.join(', ')}"
    end
  end
end

# まとめて結果を出力
puts "#{$total_created} 件のユーザアクションが追加されました。"
puts "#{$total_skipped_good} 件の 'good' アクションは既存の 'bad' アクションのためスキップされました。"
puts "#{$total_skipped_bad} 件の 'bad' アクションは既存の 'good' アクションのためスキップされました。"
puts "#{$total_failures} 件のアクションの作成に失敗しました。"
puts "#{$total_comments} 件のコメントが作成されました。"
puts "#{$total_toppings} 件のトッピングが作成されました。"
puts "#{$total_recipes} 件のレシピが作成されました。"
puts "#{$total_foodstuffs} 件の食品が作成されました。"
