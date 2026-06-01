class Game < ActiveRecord::Base
  STATUS_MODERATION = 0
  STATUS_ACCEPTED   = 1
  STATUS_REJECTED   = 2

  validates :name, :description, presence: true
  validates :cover, presence: true
  validates :game_file, presence: true

  has_one_attached :cover
  has_one_attached :game_file
  has_many :ratings
  has_many :reviews
  has_many :jam_submissions, dependent: :destroy

  after_save :check_author_achievements, if: :saved_change_to_status?

  attr_accessor :admin_edit, :moderator_edit

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10

  validate :game_file_format
  validate :game_file_size
  def jam_rating(jam_id, vote_type: nil)
    reviews_scope = reviews.where(jam_id: jam_id).where.not(user_mark: 0)

    if vote_type.present?
      vt = Review.vote_types[vote_type.to_s]
      reviews_scope = reviews_scope.where(vote_type: vt) if vt
    end

    reviews_sum = reviews_scope.sum(:user_mark)
    reviews_cnt = reviews_scope.count

    picks_scope = JamCriterionPick.where(jam_id: jam_id, game_id: id)

    if vote_type.present? && %w[jury audience].include?(vote_type.to_s)
      picks_scope = picks_scope.where(channel: vote_type.to_s)
    end

    picks_cnt = picks_scope.count
    picks_sum = picks_cnt * 5.0

    total_cnt = reviews_cnt + picks_cnt
    return 0.0 if total_cnt == 0

    ((reviews_sum + picks_sum) / total_cnt.to_f).round(1)
  end

  def overall_rating(vote_type: nil)
    scope = reviews.where(jam_id: nil).where.not(user_mark: 0)
    scope = scope.where(vote_type: vote_type) if vote_type.present?
    scope.any? ? scope.average(:user_mark).to_f.round(1) : 0.0
  end

  validates :reason, presence: true, if: -> { status == 2 }

  private

  def check_author_achievements
    AchievementService.check_and_award(author)
  end

  def game_file_format
    return unless game_file.attached?

    acceptable_types = %w[
      application/zip application/x-zip-compressed
      application/x-rar-compressed application/vnd.rar
      application/x-7z-compressed
    ]
    errors.add(:game_file, :wrong_format) unless acceptable_types.include?(game_file.content_type)
  end


  def game_file_size
    if game_file.attached? && game_file.byte_size > 100.megabytes
      errors.add(:game_file, :too_large)
    end
  end
end
