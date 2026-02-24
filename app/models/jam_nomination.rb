class JamNomination < ApplicationRecord
  belongs_to :jam

  enum :method, manual: 0, audience_based: 1

  validates :title, presence: true
end