# frozen_string_literal: true

class JamSubmission < ActiveRecord::Base
  belongs_to :game, optional: true
  belongs_to :jam
  belongs_to :user

  after_create :check_jam_author_achievements
  after_destroy :check_jam_author_achievements

  private

  def check_jam_author_achievements
    AchievementService.check_and_award(jam.author) if jam.author
  end
end
