class Game < ActiveRecord::Base
  validates :name, :description, presence: true
  validates :cover, presence: { message: "Обложка обязательна для загрузки" }
  validates :game_file, presence: { message: "Файл игры обязателен для загрузки" }

  has_one_attached :cover
  has_one_attached :game_file
  has_many :ratings
  has_many :reviews
  has_many :jam_submissions, dependent: :destroy

  attr_accessor :admin_edit, :moderator_edit

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: 'Можно выбрать не более 10 тегов'

  validate :game_file_format
  validate :game_file_size
  def jam_rating(jam_id, vote_type: nil)
    scope = reviews.where(jam_id: jam_id).where.not(user_mark: 0)
    scope = scope.where(vote_type: vote_type) if vote_type.present?
    scope.any? ? scope.average(:user_mark).to_f.round(1) : 0.0
  end

  def overall_rating(vote_type: nil)
    scope = reviews.where(jam_id: nil).where.not(user_mark: 0)
    scope = scope.where(vote_type: vote_type) if vote_type.present?
    scope.any? ? scope.average(:user_mark).to_f.round(1) : 0.0
  end

  validates :reason, presence: true, if: -> { status == 2 }

  private

  def game_file_format
    if game_file.attached?
      acceptable_types = %w[application/zip application/x-rar-compressed application/x-7z-compressed]
      unless acceptable_types.include?(game_file.content_type)
        errors.add(:game_file, "Файл должен быть в формате .zip, .rar или .7z")
      end
    end
  end


  def game_file_size
    if game_file.attached? && game_file.byte_size > 100.megabytes
      errors.add(:game_file, "Размер архива не должен превышать 100 MB")
    end
  end
end
