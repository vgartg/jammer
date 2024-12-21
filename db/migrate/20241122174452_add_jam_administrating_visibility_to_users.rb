class AddJamAdministratingVisibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :jams_administrating_visibility)
      add_column :users, :jams_administrating_visibility, :string, default: "All"
    else
      Rails.logger.warn "Column :jams_administrating_visibility already exists in :users table, skipping addition."
    end
  end
end
