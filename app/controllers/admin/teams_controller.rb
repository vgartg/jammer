module Admin
  class TeamsController < ApplicationController
    before_action :admin?

    def index
      @teams = Team.includes(:leader, :accepted_memberships).order(created_at: :desc)
      if params[:search].present?
        q = "%#{params[:search].downcase}%"
        @teams = @teams.where('LOWER(teams.name) LIKE ?', q)
      end
      @pagy, @teams = pagy(@teams, limit: 20)
    end

    def destroy
      team = Team.find(params[:id])
      if team.destroy
        create_administration_record(current_user, team, {}, 'delete')
        flash[:success] = t('admin.teams.deleted')
      else
        flash[:failure] = team.errors.full_messages
      end
      redirect_to admin_teams_path
    end
  end
end
