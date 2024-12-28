class ChangeUsersPrimaryKeyToUuid < ActiveRecord::Migration[7.0]
  def change
    # 古いIDカラムを削除
    remove_column :users, :id

    # UUIDカラムを主キーに設定
    rename_column :users, :uuid, :id
    execute 'ALTER TABLE users ADD PRIMARY KEY (id);'
  end
end
