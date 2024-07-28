class AddNotNullConstraintToCommentsBody < ActiveRecord::Migration[7.0]
  def change
    change_column_null :comments, :body, false
  end
end
