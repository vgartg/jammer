class AddJamParticipatingVisibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :jams_participating_visibility, :string, default: "All"
  end
end
