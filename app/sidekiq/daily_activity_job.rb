class DailyActivityJob < ApplicationJob
  queue_as :default

  def perform
    StatisticForDay.record_daily_activity
    User.where(is_online_today: true).update_all(is_online_today: false)
  end
end
