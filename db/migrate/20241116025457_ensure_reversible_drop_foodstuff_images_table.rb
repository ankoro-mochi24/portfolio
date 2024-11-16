class EnsureReversibleDropFoodstuffImagesTable < ActiveRecord::Migration[7.0]
  def up
    # すでにテーブルが削除済みであればスキップ
    drop_table :foodstuff_images if table_exists?(:foodstuff_images)
  end

  def down
    # 復元するテーブルの構造を記述
    create_table :foodstuff_images do |t|
      t.string :name
      t.timestamps
    end
  end
end
