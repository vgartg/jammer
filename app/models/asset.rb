class Asset < ApplicationRecord
  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_one_attached :preview
  has_many_attached :files
  has_one_attached :guide

  CATEGORIES = %w[sprite sound font shader 3d_model music sfx tileset ui other].freeze

  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :files, presence: true

  after_create :check_author_achievements

  validate :guide_format
  validate :preview_format
  validate :files_size

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :search, ->(q) { where('LOWER(assets.title) LIKE ? OR LOWER(assets.description) LIKE ?', "%#{q.downcase}%", "%#{q.downcase}%") if q.present? }

  private

  def check_author_achievements
    AchievementService.check_and_award(author)
  end

  ACCEPTABLE_GUIDE_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze
  ACCEPTABLE_GUIDE_EXTENSIONS = %w[.pdf .doc .docx].freeze

  ACCEPTABLE_PREVIEW_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  ACCEPTABLE_PREVIEW_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp].freeze

  def guide_format
    return unless guide.attached?

    type_ok = ACCEPTABLE_GUIDE_TYPES.include?(guide.content_type)
    ext_ok  = ACCEPTABLE_GUIDE_EXTENSIONS.include?(File.extname(guide.filename.to_s).downcase)
    errors.add(:guide, :wrong_format) unless type_ok && ext_ok
  end

  def preview_format
    return unless preview.attached?

    type_ok = ACCEPTABLE_PREVIEW_TYPES.include?(preview.content_type)
    ext_ok  = ACCEPTABLE_PREVIEW_EXTENSIONS.include?(File.extname(preview.filename.to_s).downcase)
    errors.add(:preview, :wrong_format) unless type_ok && ext_ok
  end

  def files_size
    files.each do |file|
      errors.add(:files, :too_large) if file.byte_size > 200.megabytes
    end
  end
end
