class Game < ActiveRecord::Base
  validates :name, :description, presence: true
end