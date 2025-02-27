class Jam < ActiveRecord::Base
  validates :name, :description, :start_date, :deadline, :end_date, presence: true
  has_one_attached :cover
  has_one_attached :logo

  attr_accessor :admin_edit, :moderator_edit

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: 'Можно выбрать не более 10 тегов'

  validates :reason, presence: true, if: -> { status == 2 }
end
