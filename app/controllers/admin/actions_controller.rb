class Admin::ActionsController < ApplicationController
  before_action :admin?

  def index
    scope = AdministrationTracking.includes(:admin).order(created_at: :desc)

    scope = scope.where(admin_id: params[:admin_id]) if params[:admin_id].present?
    scope = scope.where(structure_type: params[:resource_type]) if params[:resource_type].present?
    scope = scope.where(action: params[:action_type]) if params[:action_type].present?
    if params[:date_from].present?
      date_from = Date.parse(params[:date_from]) rescue nil
      scope = scope.where("created_at >= ?", date_from.beginning_of_day) if date_from
    end
    if params[:date_to].present?
      date_to = Date.parse(params[:date_to]) rescue nil
      scope = scope.where("created_at <= ?", date_to.end_of_day) if date_to
    end

    @admins = User.where(role: %w[admin moderator]).order(:name)
    @resource_types = AdministrationTracking.distinct.pluck(:structure_type).compact.sort
    @action_types = AdministrationTracking.distinct.pluck(:action).compact.sort
    @pagy, @actions = pagy(scope, limit: 20)
  end
end
