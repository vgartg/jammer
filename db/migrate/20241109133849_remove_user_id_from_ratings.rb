class RemoveUserIdFromRatings < ActiveRecord::Migration[8.0]
  def change
    remove_column :ratings, :user_id, :bigint
  end
end
