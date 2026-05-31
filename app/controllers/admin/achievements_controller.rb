module Admin
  class AchievementsController < ApplicationController
    before_action :admin?

    def index
      @users = User.includes(:user_achievements).order(:name)
      if params[:search].present?
        q = "%#{params[:search].downcase}%"
        @users = @users.where('LOWER(name) LIKE ? OR LOWER(email) LIKE ?', q, q)
      end
      @pagy, @users = pagy(@users, limit: 20)
      @available_achievements = AchievementService::ACHIEVEMENTS.keys
    end

    def create
      user = User.find(params[:user_id])
      key = params[:achievement_key]

      unless AchievementService::ACHIEVEMENTS.key?(key)
        flash[:failure] = t('admin.achievements.invalid_key')
        return redirect_to admin_achievements_path
      end

      begin
        achievement = user.user_achievements.create!(achievement_key: key, earned_at: Time.current)
      rescue ActiveRecord::RecordNotUnique
        flash[:failure] = t('admin.achievements.already_has')
        return redirect_to admin_achievements_path
      end
      create_administration_record(current_user, user, { achievement: key }, 'grant_achievement')
      User.create_notification(user, user, 'earned_achievement', achievement)
      flash[:success] = t('admin.achievements.granted')
      redirect_to admin_achievements_path
    end

    def destroy
      achievement = UserAchievement.find(params[:id])
      user = achievement.user
      key = achievement.achievement_key
      Notification.where(notifiable: achievement).destroy_all
      if achievement.destroy
        create_administration_record(current_user, user, { achievement: key }, 'revoke_achievement')
        flash[:success] = t('admin.achievements.revoked')
      else
        flash[:failure] = achievement.errors.full_messages
      end
      redirect_to admin_achievements_path
    end
  end
end
