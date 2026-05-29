class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notify_friend_requests, :boolean, default: true, null: false
    add_column :users, :notify_jam_invites, :boolean, default: true, null: false
    add_column :users, :notify_status_changes, :boolean, default: true, null: false
  end
end
