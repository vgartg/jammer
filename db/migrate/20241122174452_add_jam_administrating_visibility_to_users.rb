class AddJamAdministratingVisibilityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :jams_administrating_visibility, :string, default: "All"
  end
end
