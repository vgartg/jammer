class Game < ActiveRecord::Base
  validates :name, :description, :author_link, presence: true
end