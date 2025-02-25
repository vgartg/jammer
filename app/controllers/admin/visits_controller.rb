class Admin::VisitsController < ApplicationController
  before_action :admin?

  def index; end

  def registrations_data
    end_date = Date.current
    start_date = end_date - 29.days

    registrations = User.where(created_at: start_date..end_date)
                        .group("DATE(created_at)")
                        .select("DATE(created_at) as registration_date, COUNT(*) as user_count")

    daily_totals = {}
    registrations.each { |record| daily_totals[record.registration_date] = record.user_count }

    result = {}
    total_users = 0

    (start_date..end_date).each do |date|
      user_count = daily_totals[date] || 0
      total_users += user_count
      result[date.iso8601] = total_users
    end

    render json: result
  end

  def visits_data
    end_date = Date.current
    start_date = end_date - 29.days

    visits = StatisticForDay.where(created_at: start_date..end_date)
                            .group("DATE(created_at)")
                            .select("DATE(created_at) as visit_date, SUM(count_online_users) as user_count")

    daily_totals = {}
    visits.each { |record| daily_totals[record.visit_date] = record.user_count }

    result = {}

    (start_date..end_date).each do |date|
      user_count = daily_totals[date] || 0
      result[date.iso8601] = user_count
    end

    render json: result
  end
end
