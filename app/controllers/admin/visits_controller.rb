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
      result[date] = total_users
    end

    render json: result
  end

  def visits_data
    end_date = Date.current
    start_date = end_date - 29.days

    visits = User.where('last_active_at >= ?', 30.days.ago)
                 .group("DATE(last_active_at)")
                 .select("DATE(last_active_at) as visit_date, COUNT(*) as user_count")

    daily_totals = {}
    visits.each { |record| daily_totals[record.visit_date] = record.user_count }

    result = {}

    (start_date..end_date).each do |date|
      user_count = daily_totals[date] || 0
      result[date] = user_count
    end

    render json: result
  end
end
