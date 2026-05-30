class AchievementsController < ApplicationController
  def index
    @achievements = AchievementService::ACHIEVEMENTS
  end
end
