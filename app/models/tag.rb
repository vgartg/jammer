class Tag < ActiveRecord::Base
  has_and_belongs_to_many :games

  validates :name, presence: true, uniqueness: true
end
