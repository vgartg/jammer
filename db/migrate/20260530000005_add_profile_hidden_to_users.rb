class AddProfileHiddenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_hidden, :boolean, default: false, null: false
  end
end
