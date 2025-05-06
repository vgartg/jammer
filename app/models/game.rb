class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  has_one_attached :cover
  has_one_attached :game_file
  has_one_attached :html5_zip

  attr_accessor :admin_edit, :moderator_edit

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: 'Можно выбрать не более 10 тегов'

  validate :game_file_format
  validate :game_file_size

  validates :reason, presence: true, if: -> { status == 2 }

  private

  def game_file_format
    return unless game_file.attached?

    acceptable_types = %w[application/zip application/x-rar-compressed application/x-7z-compressed]
    return if acceptable_types.include?(game_file.content_type)

    errors.add(:game_file, 'Файл должен быть в формате .zip, .rar или .7z')
  end

  def game_file_size
    return unless game_file.attached? && game_file.byte_size > 100.megabytes

    errors.add(:game_file, 'Размер архива не должен превышать 100 MB')
  end
end
