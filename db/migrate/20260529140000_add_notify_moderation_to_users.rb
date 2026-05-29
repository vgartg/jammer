class AddNotifyModerationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notify_moderation, :boolean, default: true, null: false
  end
end
