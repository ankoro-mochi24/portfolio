json.extract! recipe, :id, :title, :dish_image, :user_id, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)

# 関連するステップを追加
json.steps recipe.recipe_steps do |step|
  json.extract! step, :id, :text, :step_image, :created_at, :updated_at
end

# 関連する調理器具を追加
json.kitchen_tools recipe.kitchen_tools do |tool|
  json.extract! tool, :id, :name, :created_at, :updated_at
end

# 関連する材料を追加
json.ingredients recipe.ingredients do |ingredient|
  json.extract! ingredient, :id, :name, :created_at, :updated_at
end
