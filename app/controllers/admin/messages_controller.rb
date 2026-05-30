module Admin
  class MessagesController < ApplicationController
    before_action :admin?

    def new
      @message = AdminMessage.new
      @jams = Jam.order(:name)
      @teams = Team.order(:name)
    end

    def create
      @message = AdminMessage.new(message_params.merge(sender: current_user))
      recipient_ids = []

      ApplicationRecord.transaction do
        @message.save!
        recipient_ids = resolve_recipient_ids
        send_notifications(recipient_ids)
      end

      create_administration_record(current_user, @message, {}, 'create')
      flash[:success] = t('admin.messages.sent', count: recipient_ids.size)
      redirect_to new_admin_message_path
    rescue ActiveRecord::RecordInvalid
      flash[:failure] = @message.errors.full_messages
      redirect_to new_admin_message_path
    end

    private

    def message_params
      params.require(:admin_message).permit(:title, :body)
    end

    def resolve_recipient_ids
      ids = case params[:target_type]
            when 'all'
              User.where(email_confirmed: true).where.not(id: current_user.id).pluck(:id)
            when 'user'
              raw = params[:target_user_id].to_s.strip
              return [] if raw.blank?
              user = User.find_by(id: raw.to_i.nonzero? ? raw : nil) || User.find_by(name: raw)
              user && user.email_confirmed? && user.id != current_user.id ? [user.id] : []
            when 'team'
              team = Team.find_by(id: params[:target_team_id])
              return [] unless team
              User.joins(:team_memberships)
                  .where(team_memberships: { team_id: team.id, status: 'accepted' })
                  .where(email_confirmed: true)
                  .where.not(id: current_user.id)
                  .pluck(:id)
            when 'jam'
              jam = Jam.find_by(id: params[:target_jam_id])
              return [] unless jam
              User.joins(:jam_submissions)
                  .where(jam_submissions: { jam_id: jam.id })
                  .where(email_confirmed: true)
                  .where.not(id: current_user.id)
                  .pluck(:id)
            else
              []
            end
      ids.uniq
    end

    def send_notifications(recipient_ids)
      return if recipient_ids.empty?

      now = Time.current

      Notification.insert_all(
        recipient_ids.map do |rid|
          {
            recipient_id: rid,
            actor_id: current_user.id,
            action: 'admin_message',
            notifiable_id: @message.id,
            notifiable_type: 'AdminMessage',
            read: false,
            created_at: now,
            updated_at: now
          }
        end
      )
    end
  end
end
