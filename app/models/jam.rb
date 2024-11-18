class Jam < ActiveRecord::Base
  validates :name, :start_date, :deadline, :end_date, presence: true
  validates :cover, presence: { message: "Обложка обязательна для загрузки" }
  validates :logo, presence: { message: "Логотип обязателен для загрузки" }

  has_rich_text :description

  has_one_attached :cover
  has_one_attached :logo

  has_many :jam_submissions, dependent: :destroy

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: "Можно выбрать не более 10 тегов"

  validate :description_presence

  private
  def description_presence
    if description.blank? || description.body.blank?
      errors.add(:description, "Описание обязательно для заполнения")
    end
  end
end