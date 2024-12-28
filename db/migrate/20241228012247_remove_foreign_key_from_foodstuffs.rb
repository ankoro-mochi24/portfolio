class RemoveForeignKeyFromFoodstuffs < ActiveRecord::Migration[7.0]
  def change
    if foreign_key_exists?(:foodstuffs, :users)
      remove_foreign_key :foodstuffs, :users
    end
  end
end
