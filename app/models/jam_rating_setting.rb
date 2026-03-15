class JamRatingSetting < ApplicationRecord
  belongs_to :jam

  validate :at_least_one_enabled

  private

  def at_least_one_enabled
    if !jury_enabled && !audience_enabled
      errors.add(:base, "Нельзя выключить и жюри, и аудиторию одновременно")
    end
  end
end