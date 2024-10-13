class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  has_one_attached :cover
  has_one_attached :game_file

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: "Можно выбрать не более 10 тегов"
  validate :game_file_format

  private
  def game_file_format
    if game_file.attached? && game_file.content_type != 'application/zip'
      errors.add(:game_file, "Файл должен быть в формате .zip")
    end
  end

end