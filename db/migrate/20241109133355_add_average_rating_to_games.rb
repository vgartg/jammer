class AddAverageRatingToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :average_rating, :float
  end
end
