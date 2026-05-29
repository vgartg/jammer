class AddGamesAndParticipantsToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :games, :integer, array: true, default: [], if_not_exists: true
    add_column :jams, :participants, :integer, array: true, default: [], if_not_exists: true
  end
end
