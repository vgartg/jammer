class Admin::VisitsController < ApplicationController
  before_action :admin?

  def index; end

  def registrations_data
    days = params[:days].to_i
    end_date = Date.current
    start_date = end_date - days.days
    result = {}

    (start_date..end_date).each do |date|
      total_users = User.where("DATE(created_at) = ?", date).count
      result[date] = total_users
    end

    render json: result
  end

  def visits_data
    days = params[:days].to_i
    end_date = Date.current
    start_date = end_date - days.days
    result = {}

    (start_date..end_date).each do |date|
      total_users = StatisticForDay.where("DATE(created_at) = ?", date).pluck(:count_online_users).sum
      result[date] = total_users
    end

    render json: result
  end
end
