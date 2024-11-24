class AddParticipantsIdToJams < ActiveRecord::Migration[8.0]
  def change
    add_column :jams, :participantsId, :bigint, array:true, default: []
  end
end
