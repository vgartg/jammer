class TeamsController < ApplicationController
  before_action :authenticate_user, only: %i[new create edit update destroy]
  before_action :set_team, only: %i[show edit update destroy]
  before_action :authorize_team!, only: %i[edit update destroy]

  def index
    @teams = Team.order(created_at: :desc)
    if params[:search].present?
      q = "%#{params[:search].downcase}%"
      @teams = @teams.where('LOWER(teams.name) LIKE ? OR LOWER(teams.description) LIKE ?', q, q)
    end
    @pagy, @teams = pagy(@teams.includes(:accepted_memberships, :leader), limit: 12)
  end

  def show
    all_memberships = @team.team_memberships.includes(user: { avatar_attachment: :blob }).to_a
    @memberships = all_memberships.select { |m| m.status == 'accepted' }
    @pending_memberships = all_memberships.select { |m| m.status == 'pending' }
    @user_membership = current_user ? all_memberships.find { |m| m.user_id == current_user.id } : nil

    if (current_user == @team.leader || current_user&.admin?) && params[:invite_search_q].present?
      q = "%#{params[:invite_search_q].downcase}%"
      excluded_ids = all_memberships.select { |m| %w[pending accepted].include?(m.status) }.map(&:user_id) + [@team.leader_id]
      @invite_results = User.where.not(id: excluded_ids).where('LOWER(name) LIKE ?', q).limit(10)
    end
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params.merge(leader: current_user))
    if @team.save
      flash[:success] = t('teams.create.success')
      redirect_to team_profile_path(@team)
    else
      flash[:failure] = @team.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      flash[:success] = t('teams.update.success')
      redirect_to team_profile_path(@team)
    else
      flash[:failure] = @team.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @team.destroy
      flash[:success] = t('teams.destroy.success')
    else
      flash[:failure] = @team.errors.full_messages
    end
    redirect_to teams_path
  end

  def invite_search
    @team = Team.find(params[:id])
    unless current_user && (current_user == @team.leader || current_user.admin?)
      render json: { error: 'Forbidden' }, status: :forbidden and return
    end
    q = params[:q].to_s.strip.downcase
    if q.length >= 2
      users = User.where.not(id: @team.team_memberships.where(status: %w[pending accepted]).select(:user_id))
                  .where.not(id: @team.leader_id)
                  .where('LOWER(name) LIKE ?', "%#{q}%")
                  .limit(10)
      render json: users.map { |u| { id: u.id, name: u.name } }
    else
      render json: []
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def authorize_team!
    return if current_user == @team.leader || current_user.admin?

    flash[:failure] = t('controllers.application.insufficient_rights')
    redirect_to dashboard_path
  end

  def team_params
    params.require(:team).permit(:name, :description, :avatar, :open_membership)
  end
end
