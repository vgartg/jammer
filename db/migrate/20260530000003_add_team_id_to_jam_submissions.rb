class AddTeamIdToJamSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :jam_submissions, :team_id, :integer
    add_index :jam_submissions, :team_id
    add_foreign_key :jam_submissions, :teams, column: :team_id
  end
end
