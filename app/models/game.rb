class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  has_one_attached :cover

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'
end