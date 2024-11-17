class AddParticipantsToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :participants, :integer, array: true, default: []
  end
end
