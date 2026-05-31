class AchievementsController < ApplicationController
  def index
    @achievements = AchievementService::ACHIEVEMENTS
    @earned_keys = current_user ? current_user.user_achievements.pluck(:achievement_key).to_set : Set.new
  end

  def panel
    return head(:forbidden) unless @current_user

    @progress    = AchievementService.category_progress(@current_user)
    @earned_keys = @current_user.user_achievements.pluck(:achievement_key).to_set
    render partial: 'achievements/sidebar_panel',
           locals: { progress: @progress, earned_keys: @earned_keys },
           layout: false
  end
end
