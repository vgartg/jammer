class StatisticForDay < ApplicationRecord
  def self.record_daily_activity
    active_user_count = User.where(is_online_today: true).count
    create(count_online_users: active_user_count, created_at: DateTime.now)
  end
end
