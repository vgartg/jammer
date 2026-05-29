class Announcement < ApplicationRecord
  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  TYPES = %w[general release].freeze

  validates :title_en, :title_ru, presence: true
  validates :announcement_type, inclusion: { in: TYPES }
  validates :version, format: { with: /\A\d+\.\d+\.\d+\z/, message: :invalid_version }, allow_blank: true
  validates :version, presence: true, if: -> { announcement_type == 'release' }

  scope :published, -> { where(published: true).order(published_at: :desc) }

  def title(locale = I18n.locale)
    locale.to_sym == :ru ? title_ru : title_en
  end

  def body(locale = I18n.locale)
    locale.to_sym == :ru ? body_ru : body_en
  end

  def publish!
    update!(published: true, published_at: Time.current)
  end
end
