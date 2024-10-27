class AddUsersCanVotesToJam < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :users_can_votes, :boolean, default: false
  end
end
