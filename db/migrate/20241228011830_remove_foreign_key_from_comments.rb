class RemoveForeignKeyFromComments < ActiveRecord::Migration[7.0]
  def change
    if foreign_key_exists?(:comments, :users)
      remove_foreign_key :comments, :users
    end
  end
end
