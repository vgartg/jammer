class DailyActivityJob < ApplicationJob
  queue_as :default

  def perform
    StatisticForDays.record_daily_activity
  end
end
