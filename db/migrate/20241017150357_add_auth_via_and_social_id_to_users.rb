class AddAuthViaAndSocialIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :auth_via, :string, default: "native"
    add_column :users, :social_id, :string
  end
end
