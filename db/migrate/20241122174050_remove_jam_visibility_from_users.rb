class RemoveJamVisibilityFromUsers < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:users, :jams_visibility)
      remove_column :users, :jams_visibility, :string
    else
      Rails.logger.warn "Column :jams_visibility does not exist in :users table, skipping removal."
    end
  end
end
