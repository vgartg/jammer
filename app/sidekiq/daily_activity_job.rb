class DailyActivityJob < ApplicationJob
  queue_as :default

  def perform
    StatisticForDay.record_daily_activity
  end
end
