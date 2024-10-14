class Tag < ActiveRecord::Base
  has_and_belongs_to_many :games
  has_and_belongs_to_many :jams

  validates :name, presence: true, uniqueness: true
end
