# db/seeds.rb

require 'faker'

# ユーザーのサンプルデータを作成（ユーザーがいない場合のため）
5.times do
  User.create(
    email: Faker::Internet.email,
    password: 'password',
    password_confirmation: 'password',
    name: Faker::Name.name
  )
end
=begin
# レシピのサンプルデータを作成
10.times do
  recipe = Recipe.new(
    title: Faker::Food.dish,
    user_id: User.pluck(:id).sample
  )
  recipe.dish_image = File.open(Rails.root.join('app/assets/images/sample.jpg'))

  # 材料を追加
  3.times do
    ingredient = Ingredient.find_or_create_by(name: Faker::Food.ingredient)
    recipe.recipe_ingredients.build(ingredient: ingredient)
  end

  # 調理器具を追加
  3.times do
    kitchen_tool = KitchenTool.find_or_create_by(name: Faker::Appliance.equipment)
    recipe.recipe_kitchen_tools.build(kitchen_tool: kitchen_tool, kitchen_tool_name: kitchen_tool.name)
  end

  if recipe.save
    # レシピステップを追加
    3.times do
      step = recipe.recipe_steps.build(
        text: Faker::Food.description
      )
      step.step_image = File.open(Rails.root.join('app/assets/images/sample.jpg'))
      step.save
    end
  else
    puts "Recipe creation failed: #{recipe.errors.full_messages.join(", ")}"
  end
end
=end
# 食品のサンプルデータを作成
30.times do
  foodstuff = Foodstuff.new(
    name: Faker::Food.ingredient,
    price: Faker::Commerce.price(range: 1..100.0).to_i, # 価格を整数に変換
    description: Faker::Food.description,
    link: Faker::Internet.url,
    user_id: User.pluck(:id).sample,
    image: [File.open(Rails.root.join('app/assets/images/sample.jpg'))] # ファイルオブジェクトとして設定
  )

  if foodstuff.save
  else
    puts "Foodstuff creation failed: #{foodstuff.errors.full_messages.join(", ")}"
  end
end

puts "サンプルデータの作成が完了しました！"
