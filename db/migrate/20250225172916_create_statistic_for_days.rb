class CreateStatisticForDays < ActiveRecord::Migration[8.0]
  def change
    create_table :statistic_for_days do |t|
      t.integer :count_online_users, null: false, default: 0
      t.timestamps
    end
  end
end
