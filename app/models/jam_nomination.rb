class JamNomination < ApplicationRecord
  belongs_to :jam
  belongs_to :winner_game, class_name: "Game", optional: true

  validates :title, presence: true
end