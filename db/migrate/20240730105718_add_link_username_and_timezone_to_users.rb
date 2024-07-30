class AddLinkUsernameAndTimezoneToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :link_username, :string
    add_column :users, :timezone, :string
  end
end
