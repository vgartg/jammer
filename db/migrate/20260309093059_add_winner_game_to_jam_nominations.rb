class AddWinnerGameToJamNominations < ActiveRecord::Migration[8.0]
  def change
    add_column :jam_nominations, :winner_game_id, :integer
    add_index  :jam_nominations, :winner_game_id
    add_foreign_key :jam_nominations, :games, column: :winner_game_id
  end
end