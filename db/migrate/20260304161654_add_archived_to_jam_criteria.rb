class AddArchivedToJamCriteria < ActiveRecord::Migration[8.0]
  def change
    add_column :jam_criteria, :archived, :boolean, null: false, default: false
    add_index  :jam_criteria, [:jam_id, :archived]
  end
end