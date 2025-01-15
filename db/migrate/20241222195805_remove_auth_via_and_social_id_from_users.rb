class RemoveAuthViaAndSocialIdFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :auth_via, :string if column_exists?(:users, :auth_via)
    remove_column :users, :social_id, :string if column_exists?(:users, :social_id)
  end
end
