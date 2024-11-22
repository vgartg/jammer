class RemoveJamVisibilityFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :jams_visibility, :string
  end
end
