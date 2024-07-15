class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  has_one_attached :cover
end