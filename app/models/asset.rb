class Asset < ApplicationRecord
  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_one_attached :preview
  has_many_attached :files
  has_one_attached :guide

  CATEGORIES = %w[sprite sound font shader 3d_model music sfx tileset ui other].freeze

  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :files, presence: true

  validate :guide_format
  validate :preview_format
  validate :files_size

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :search, ->(q) { where('LOWER(assets.title) LIKE ? OR LOWER(assets.description) LIKE ?', "%#{q.downcase}%", "%#{q.downcase}%") if q.present? }

  private

  def guide_format
    return unless guide.attached?

    acceptable = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
    ]
    errors.add(:guide, :wrong_format) unless acceptable.include?(guide.content_type)
  end

  def preview_format
    return unless preview.attached?

    acceptable = %w[image/jpeg image/png image/gif image/webp]
    errors.add(:preview, :wrong_format) unless acceptable.include?(preview.content_type)
  end

  def files_size
    files.each do |file|
      errors.add(:files, :too_large) if file.byte_size > 200.megabytes
    end
  end
end
