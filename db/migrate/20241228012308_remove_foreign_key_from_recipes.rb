class RemoveForeignKeyFromRecipes < ActiveRecord::Migration[7.0]
  def change
    if foreign_key_exists?(:recipes, :users)
      remove_foreign_key :recipes, :users
    end
  end
end
