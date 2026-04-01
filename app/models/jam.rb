class Jam < ActiveRecord::Base
  validates :name, :start_date, :deadline, :end_date, presence: true
  validates :cover, presence: { message: "Обложка обязательна для загрузки" }
  validates :logo, presence: { message: "Логотип обязателен для загрузки" }

  has_rich_text :description

  has_one_attached :cover
  has_one_attached :logo

  attr_accessor :admin_edit, :moderator_edit

  has_many :jam_submissions, dependent: :destroy

  has_many :jam_contributors, dependent: :destroy
  has_many :contributors, through: :jam_contributors, source: :user

  has_one :jam_rating_setting, dependent: :destroy
  has_many :jam_criteria, class_name: "JamCriterion", dependent: :destroy
  has_many :jam_nominations, class_name: "JamNomination", dependent: :destroy

  def rating_setting
    jam_rating_setting || create_jam_rating_setting
  end

  def contributor_record(user)
    return nil unless user
    jam_contributors.find_by(user_id: user.id, status: "accepted")
  end

  # Операционное управление джемом: edit/update/destroy, remove_participant/remove_project и т.п.
  def can_manage?(user)
    return false unless user
    return true if user == author

    jc = contributor_record(user)
    return false unless jc

    jc.host? || jc.admin?
  end

  # "Глобальные настройки" джема: настройки оценок и жюри
  def can_configure?(user)
    return false unless user
    return true if user == author

    jc = contributor_record(user)
    return false unless jc

    jc.host? # только host (и автор)
  end

  def judge?(user)
    jc = contributor_record(user)
    jc.present? && jc.judge?
  end

  def voting_open?
    return false if start_date.blank? || end_date.blank?
    today = Date.current
    today >= start_date && today <= end_date
  end

  def can_vote_as_jury?(user)
    return false unless user
    return false unless rating_setting.jury_enabled
    return false unless voting_open?
    judge?(user)
  end

  def can_vote_as_audience?(user)
    return false unless user
    return false unless rating_setting.audience_enabled
    return false unless voting_open?
    return false if judge?(user)
    true
  end

  def submission_open?
    return false if start_date.blank? || deadline.blank?
    today = Date.current
    today >= start_date && today <= deadline
  end

  def submission_closed?
    !submission_open?
  end

  def hosts
    jam_contributors.includes(:user).where(status: "accepted", host: true).map(&:user)
  end

  belongs_to :author, foreign_key: 'author_id', class_name: 'User'

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: 'Можно выбрать не более 10 тегов'

  validates :reason, presence: true, if: -> { status == 2 }
  validates_length_of :tags, maximum: 10, message: "Можно выбрать не более 10 тегов"

  validate :description_presence

  private
  def description_presence
    if description.blank? || description.body.blank?
      errors.add(:description, "Описание обязательно для заполнения")
    end
  end
end
