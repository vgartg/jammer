class AddParticipantsToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :participants, :integer, array: true, default: [] unless column_exists?(:jams, :participants)
  end
end
