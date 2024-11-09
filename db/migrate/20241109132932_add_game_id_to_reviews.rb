class AddGameIdToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :game_id, :integer
  end
end
