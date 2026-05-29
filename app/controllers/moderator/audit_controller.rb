module Moderator
  class AuditController < ApplicationController
    before_action :moderator?

    ALLOWED_ACTIONS = %w[edit delete create].freeze
    ALLOWED_TYPES   = %w[Game Jam User].freeze

    def index
      records = AdministrationTracking.includes(:admin).order(created_at: :desc)
      records = records.where(admin_id: params[:admin_id]) if params[:admin_id].present?
      records = records.where(action: params[:action_type]) if params[:action_type].in?(ALLOWED_ACTIONS)
      records = records.where(structure_type: params[:structure_type]) if params[:structure_type].in?(ALLOWED_TYPES)
      records = (records.where('created_at >= ?', Date.parse(params[:date_from])) rescue records) if params[:date_from].present?
      records = (records.where('created_at <= ?', Date.parse(params[:date_to]).end_of_day) rescue records) if params[:date_to].present?
      @pagy, @records = pagy(records, limit: 25)
      @admins = User.where(role: %i[admin moderator]).order(:name)
    end
  end
end
