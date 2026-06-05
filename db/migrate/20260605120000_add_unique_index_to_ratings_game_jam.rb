class AddUniqueIndexToRatingsGameJam < ActiveRecord::Migration[8.0]
  def change
    add_index :ratings, [:game_id, :jam_id], unique: true, if_not_exists: true
  end
end
