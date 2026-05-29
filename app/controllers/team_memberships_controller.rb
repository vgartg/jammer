class TeamMembershipsController < ApplicationController
  before_action :authenticate_user
  before_action :set_team

  def create
    if @team.member?(current_user)
      flash[:failure] = t('team_memberships.create.already_member')
      return redirect_to team_profile_path(@team)
    end

    if @team.team_memberships.exists?(user: current_user, status: 'pending')
      flash[:failure] = t('team_memberships.create.request_pending')
      return redirect_to team_profile_path(@team)
    end

    begin
      @team.team_memberships.create!(user: current_user, role: 'member', status: 'pending')
      flash[:success] = t('team_memberships.create.success')
    rescue ActiveRecord::RecordNotUnique
      flash[:failure] = t('team_memberships.create.request_pending')
    end
    redirect_to team_profile_path(@team)
  end

  def update
    @membership = @team.team_memberships.find(params[:id])

    unless current_user == @team.leader || current_user.admin?
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    allowed_statuses = %w[accepted declined]
    unless allowed_statuses.include?(params[:status])
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    @membership.update!(status: params[:status])
    flash[:success] = t('team_memberships.update.success')
    redirect_to team_profile_path(@team)
  end

  def destroy
    @membership = @team.team_memberships.find(params[:id])

    is_leader_membership = @membership.user == @team.leader
    can_remove = !is_leader_membership &&
                 (current_user == @team.leader ||
                  current_user == @membership.user ||
                  current_user.admin?)

    unless can_remove
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    @membership.destroy
    flash[:success] = t('team_memberships.destroy.success')
    redirect_to team_profile_path(@team)
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end
end
