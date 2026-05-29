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
    @pagy, @teams = pagy(@teams, limit: 12)
  end

  def show
    @memberships = @team.team_memberships.where(status: 'accepted').includes(:user)
    @pending_memberships = @team.team_memberships.where(status: 'pending').includes(:user)
    @user_membership = current_user ? @team.team_memberships.find_by(user: current_user) : nil
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
    @team.destroy
    flash[:success] = t('teams.destroy.success')
    redirect_to teams_path
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
    params.require(:team).permit(:name, :description, :avatar)
  end
end
