class AddUserIdToJamSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :jam_submissions, :user_id, :integer
  end
end
