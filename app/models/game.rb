class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  has_one_attached :cover

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: "Можно выбрать не более 10 тегов"
end