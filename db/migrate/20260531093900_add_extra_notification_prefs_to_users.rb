class AddExtraNotificationPrefsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notify_achievements,   :boolean, default: true, null: false
    add_column :users, :notify_team_invites,   :boolean, default: true, null: false
    add_column :users, :notify_admin_messages, :boolean, default: true, null: false
  end
end
