class RemoveAverageRatingFromGames < ActiveRecord::Migration[8.0]
  def change
    remove_column :games, :average_rating, :float
  end
end
