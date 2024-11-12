class RemoveUserMarkFromRatings < ActiveRecord::Migration[8.0]
  def change
    remove_column :ratings, :user_mark, :integer
  end
end
