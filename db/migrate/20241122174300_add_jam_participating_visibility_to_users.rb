class AddJamParticipatingVisibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :jams_participating_visibility)
      add_column :users, :jams_participating_visibility, :string, default: "All"
    else
      Rails.logger.warn "Column :jams_participating_visibility already exists in :users table, skipping addition."
    end
  end
end
