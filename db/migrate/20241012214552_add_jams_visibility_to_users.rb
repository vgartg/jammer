class AddJamsVisibilityToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :jams_visibility, :string, default: 'All'
  end
end
