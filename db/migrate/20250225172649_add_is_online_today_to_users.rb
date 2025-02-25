class AddIsOnlineTodayToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_online_today, :boolean, default: false
  end
end
