class TeamMembershipsController < ApplicationController
  before_action :authenticate_user
  before_action :set_team

  def create
    if current_user == @team.leader
      flash[:failure] = t('team_memberships.create.already_member')
      return redirect_to team_profile_path(@team)
    end

    join_status = @team.open_membership? ? 'accepted' : 'pending'

    existing = @team.team_memberships.find_by(user: current_user)
    if existing
      case existing.status
      when 'accepted'
        flash[:failure] = t('team_memberships.create.already_member')
        return redirect_to team_profile_path(@team)
      when 'pending'
        flash[:failure] = t('team_memberships.create.request_pending')
        return redirect_to team_profile_path(@team)
      when 'declined'
        if existing.update(status: join_status, leader_invited: false)
          flash[:success] = join_status == 'accepted' ? t('team_memberships.create.joined') : t('team_memberships.create.success')
        else
          flash[:failure] = existing.errors.full_messages
        end
        return redirect_to team_profile_path(@team)
      end
    end

    begin
      @team.team_memberships.create!(user: current_user, role: 'member', status: join_status)
      flash[:success] = join_status == 'accepted' ? t('team_memberships.create.joined') : t('team_memberships.create.success')
    rescue ActiveRecord::RecordNotUnique
      flash[:failure] = t('team_memberships.create.already_member')
    end
    redirect_to team_profile_path(@team)
  end

  def invite
    unless current_user == @team.leader || current_user.admin?
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    user = User.find_by(id: params[:user_id])
    unless user
      flash[:failure] = t('team_memberships.invite.user_not_found')
      return redirect_to team_profile_path(@team)
    end

    if user == @team.leader
      flash[:failure] = t('team_memberships.invite.already_member')
      return redirect_to team_profile_path(@team)
    end

    existing = @team.team_memberships.find_by(user: user)
    membership = if existing
      if %w[pending accepted].include?(existing.status)
        flash[:failure] = t('team_memberships.invite.already_member')
        return redirect_to team_profile_path(@team)
      else
        unless existing.update(status: 'pending', leader_invited: true)
          flash[:failure] = existing.errors.full_messages
          return redirect_to team_profile_path(@team)
        end
        existing
      end
    else
      begin
        @team.team_memberships.create!(user: user, role: 'member', status: 'pending', leader_invited: true)
      rescue ActiveRecord::RecordNotUnique
        flash[:failure] = t('team_memberships.invite.already_member')
        return redirect_to team_profile_path(@team)
      end
    end
    User.create_notification(user, current_user, 'team_invite_received', membership)
    flash[:success] = t('team_memberships.invite.success')
    redirect_to team_profile_path(@team)
  end

  def update
    @membership = @team.team_memberships.find(params[:id])

    allowed_statuses = %w[accepted declined]
    unless allowed_statuses.include?(params[:status])
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    if @membership.user == @team.leader
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    unless @membership.status == 'pending'
      flash[:failure] = t('controllers.application.insufficient_rights')
      return redirect_to team_profile_path(@team)
    end

    if @membership.leader_invited?
      unless current_user == @membership.user || current_user.admin?
        flash[:failure] = t('controllers.application.insufficient_rights')
        return redirect_to team_profile_path(@team)
      end
    else
      unless current_user == @team.leader || current_user.admin?
        flash[:failure] = t('controllers.application.insufficient_rights')
        return redirect_to team_profile_path(@team)
      end
    end

    if @membership.update(status: params[:status])
      flash[:success] = t('team_memberships.update.success')
    else
      flash[:failure] = @membership.errors.full_messages
    end
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

    if @membership.destroy
      flash[:success] = t('team_memberships.destroy.success')
    else
      flash[:failure] = @membership.errors.full_messages
    end
    redirect_to team_profile_path(@team)
  end

  private

  def set_team
    @team = Team.find(params[:team_id] || params[:id])
  end
end
