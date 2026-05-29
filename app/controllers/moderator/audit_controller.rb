module Moderator
  class AuditController < ApplicationController
    before_action :authenticate_user
    before_action :moderator?

    ALLOWED_ACTIONS = %w[edit delete create].freeze
    ALLOWED_TYPES   = %w[Game Jam User].freeze

    def index
      records = AdministrationTracking.includes(:admin).order(created_at: :desc)
      records = records.where(admin_id: params[:admin_id]) if params[:admin_id].present?
      records = records.where(action: params[:action_type]) if params[:action_type].in?(ALLOWED_ACTIONS)
      records = records.where(structure_type: params[:structure_type]) if params[:structure_type].in?(ALLOWED_TYPES)

      if params[:date_from].present?
        date_from = begin
          Date.parse(params[:date_from])
        rescue ArgumentError
          nil
        end
        records = records.where('created_at >= ?', date_from) if date_from
      end
      if params[:date_to].present?
        date_to = begin
          Date.parse(params[:date_to])
        rescue ArgumentError
          nil
        end
        records = records.where('created_at <= ?', date_to.end_of_day) if date_to
      end

      @pagy, @records = pagy(records, limit: 25)
      @admins = User.where(role: %i[admin moderator]).order(:name)
    end
  end
end
