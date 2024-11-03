# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_11_03_072915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "foodstuffs", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, null: false
    t.text "description"
    t.string "link", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image", null: false
    t.index ["user_id"], name: "index_foodstuffs_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kitchen_tools", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id"], name: "index_recipe_ingredients_on_recipe_id_and_ingredient_id", unique: true
  end

  create_table "recipe_kitchen_tools", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "kitchen_tool_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitchen_tool_id"], name: "index_recipe_kitchen_tools_on_kitchen_tool_id"
    t.index ["recipe_id", "kitchen_tool_id"], name: "index_recipe_kitchen_tools_on_recipe_id_and_kitchen_tool_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_kitchen_tools_on_recipe_id"
  end

  create_table "recipe_steps", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.text "text", null: false
    t.string "step_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "title", null: false
    t.string "dish_image", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "toppings", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "user_id", null: false
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "name"], name: "index_toppings_on_recipe_id_and_name", unique: true
    t.index ["recipe_id"], name: "index_toppings_on_recipe_id"
    t.index ["user_id"], name: "index_toppings_on_user_id"
  end

  create_table "user_actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action_type", null: false
    t.string "actionable_type", null: false
    t.bigint "actionable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "actionable_type", "actionable_id", "action_type"], name: "index_user_actions_on_user_and_actionable_and_action_type", unique: true
  end

  create_table "user_kitchen_tools", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "kitchen_tool_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitchen_tool_id"], name: "index_user_kitchen_tools_on_kitchen_tool_id"
    t.index ["user_id", "kitchen_tool_id"], name: "index_user_kitchen_tools_on_user_id_and_kitchen_tool_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "line_notify_token"
    t.boolean "notify_enabled", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "users"
  add_foreign_key "foodstuffs", "users"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes", on_delete: :cascade
  add_foreign_key "recipe_kitchen_tools", "kitchen_tools"
  add_foreign_key "recipe_kitchen_tools", "recipes", on_delete: :cascade
  add_foreign_key "recipe_steps", "recipes"
  add_foreign_key "recipes", "users"
  add_foreign_key "toppings", "recipes"
  add_foreign_key "toppings", "users"
  add_foreign_key "user_actions", "users"
  add_foreign_key "user_kitchen_tools", "kitchen_tools"
  add_foreign_key "user_kitchen_tools", "users"
end
