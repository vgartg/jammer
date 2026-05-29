class User < ActiveRecord::Base
  include Recoverable
  include Rememberable
  include Confirmable

  has_secure_token :password_reset_token
  has_secure_token :email_confirm_token

  enum :role, basic: 0, moderator: 1, admin: 2

  VISIBILITY_ALL = 'All'
  VISIBILITY_FRIENDS = 'Friends'
  VISIBILITY_NONE = 'None'

  THEME_LIGHT = 'Light'
  THEME_DARK = 'Dark'

  attr_accessor :admin_edit, :current_password, :oauth_requested_name

  validates :name, :email, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: true, on: :create, unless: :oauth_user?
  validates :password, confirmation: true, unless: :oauth_user?

  validates :visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
  # validates :jams_administrating_visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
  validates :jams_participating_visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
  validates :theme, inclusion: { in: [THEME_LIGHT, THEME_DARK] }

  validate :password_length, on: :create, unless: :oauth_user?
  has_secure_password validations: false
  has_one_attached :avatar
  has_one_attached :background_image
  has_many :games, foreign_key: 'author_id', dependent: :destroy
  has_many :jams, foreign_key: 'author_id', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

  has_many :jam_submissions

  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user, dependent: :destroy

  has_many :sessions, dependent: :destroy

  has_many :notifications, class_name: 'Notification', foreign_key: 'recipient_id', dependent: :destroy
  has_many :actor_notifications, class_name: 'Notification', foreign_key: 'actor_id', dependent: :destroy

  has_many :jam_contributors, dependent: :destroy
  has_many :contributed_jams, through: :jam_contributors, source: :jam

  def oauth_user?
    provider.present?
  end

  def oauth_name_changed?
    oauth_requested_name.present? && oauth_requested_name != name
  end

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid.to_s)
    return user if user

    user = find_by(email: auth.info.email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid.to_s)
      return user
    end

    requested_name = oauth_name_from(auth)
    unique_name = generate_unique_name(requested_name)

    user = new(
      name: unique_name,
      email: auth.info.email,
      provider: auth.provider,
      uid: auth.uid.to_s,
      email_confirmed: true,
      visibility: VISIBILITY_ALL,
      jams_participating_visibility: VISIBILITY_ALL,
      jams_administrating_visibility: VISIBILITY_ALL,
      theme: THEME_LIGHT
    )
    user.oauth_requested_name = requested_name
    user.save!
    user
  end

  def self.oauth_name_from(auth)
    candidates = [
      auth.info.try(:nickname),
      auth.info.name&.gsub(/\s+/, '_')&.downcase,
      auth.info.email&.split('@')&.first
    ]
    candidates.lazy.filter_map { |raw| sanitize_oauth_name(raw) }.first || 'user'
  end

  def self.sanitize_oauth_name(raw)
    name = raw.to_s.gsub(/[^a-zA-Z0-9_]/, '_').gsub(/__+/, '_').gsub(/\A_+|_+\z/, '')
    name.presence&.slice(0, 30)
  end

  def self.generate_unique_name(base)
    return base unless exists?(name: base)

    n = 1
    loop do
      candidate = "#{base[0..26]}_#{n}"
      return candidate unless exists?(name: candidate)

      n += 1
    end
  end

  def password_length
    return unless password.nil? || password.length < 5

    errors.add(:password, type: :invalid, message: 'must be at least 5 characters long')
  end

  def friend_request(user)
    friendships.create(friend: user)
  end

  def accept_friend_request(user)
    friendship = friendships.find_by(friend: user)
    inverse_friendship = inverse_friendships.find_by(user: user)

    if friendship
      friendship.update(status: 'accepted')
      create_notification(friendship.user, user, 'accepted_friend_request', friendship)
    elsif inverse_friendship
      inverse_friendship.update(status: 'accepted')
      create_notification(inverse_friendship.friend, user, 'accepted_friend_request', inverse_friendship)
    end
  end

  FRIEND_REQUEST_ACTIONS = %w[sent_friend_request accepted_friendship accepted_friend_request].freeze
  JAM_INVITE_ACTIONS     = %w[sent_jam_jury_invite accepted_jam_jury_invite].freeze
  STATUS_CHANGE_ACTIONS  = %w[game_status_changed jam_status_changed].freeze

  def create_notification(recipient, actor, action, notifiable)
    return if notification_muted?(recipient, action)

    existing_notifications = Notification.where(recipient: recipient, actor: actor, action: action,
                                                notifiable: notifiable)
    existing_notifications.destroy_all if existing_notifications.any?
    Notification.create(recipient: recipient, actor: actor, action: action, notifiable: notifiable)
  end

  private

  def notification_muted?(recipient, action)
    return false unless recipient.is_a?(User)

    (FRIEND_REQUEST_ACTIONS.include?(action) && !recipient.notify_friend_requests?) ||
      (JAM_INVITE_ACTIONS.include?(action)   && !recipient.notify_jam_invites?) ||
      (STATUS_CHANGE_ACTIONS.include?(action) && !recipient.notify_status_changes?)
  end

  public

  def remove_friend(user)
    friendship = friendships.find_by(friend: user)
    friendship.destroy if friendship
  end

  def friendship_with(user)
    friendships.find_by(friend_id: user.id) || user.friendships.find_by(friend_id: id)
  end

  def friend_status(user)
    friendship = friendship_with(user)
    return 'none' unless friendship

    friendship.status
  end

  def online?
    last_active_at.present? && last_active_at > 1.minutes.ago
  end

  def invalidate_other_sessions(current_session_id)
    sessions.where.not(session_id: current_session_id).destroy_all
    update(last_active_at: Time.current)
  end

  def can_see_online?(other_user)
    case visibility
    when VISIBILITY_ALL
      true
    when VISIBILITY_FRIENDS
      active_friendships = friendships.where(status: 'accepted').pluck(:friend_id) +
                           inverse_friendships.where(status: 'accepted').pluck(:user_id)
      active_friendships.include?(other_user.id) if other_user
    when VISIBILITY_NONE
      false
    end
  end

  def can_see_administrating_jams?(other_user)
    case self.jams_administrating_visibility
    when VISIBILITY_ALL
      return true
    when VISIBILITY_FRIENDS
      active_friendships = self.friendships.where(status: 'accepted').pluck(:friend_id) +
        self.inverse_friendships.where(status: 'accepted').pluck(:user_id)
      return active_friendships.include?(other_user.id) if other_user
    when VISIBILITY_NONE
      return false
    end
  end

  def can_see_participating_jams?(other_user)
    case self.jams_participating_visibility
    when VISIBILITY_ALL
      return true
    when VISIBILITY_FRIENDS
      active_friendships = self.friendships.where(status: 'accepted').pluck(:friend_id) +
        self.inverse_friendships.where(status: 'accepted').pluck(:user_id)
      return active_friendships.include?(other_user.id) if other_user
    when VISIBILITY_NONE
      return false
    end
  end

  def get_all_participating_jams
    Jam.joins("JOIN jam_submissions ON (jams.id=jam_submissions.jam_id)").where('jam_submissions.user_id = ? AND jams.status = 1', self.id)
  end

  def authenticate_password_reset_token(token)
    return false if password_reset_token.blank? || token.blank?

    BCrypt::Password.new(password_reset_token).is_password?(token)
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def authenticate_email_confirm_token(token)
    return false unless email_confirm_token.present?

    BCrypt::Password.new(email_confirm_token).is_password?(token)
  end

  def frozen?
    is_frozen?
  end

  def freeze!(reason:, duration:)
    update!(
      is_frozen: true,
      frozen_at: Time.current,
      unfreeze_at: duration == "forever" ? nil : Time.current + duration.to_i,
      frozen_reason: reason
    )
  end

  def unfreeze!
    update!(is_frozen: false, frozen_at: nil, unfreeze_at: nil, frozen_reason: nil)
  end

  def administrated_jams_with_roles
    result = {}

    # Автор
    jams.where(status: 1).find_each do |jam|
      result[jam.id] ||= { jam:, roles: [] }
      result[jam.id][:roles] << :author
    end

    # Host/Admin
    jam_contributors.includes(:jam).where(status: "accepted").find_each do |contributor|
      next unless contributor.host? || contributor.admin?
      next unless contributor.jam&.status == 1

      result[contributor.jam_id] ||= { jam: contributor.jam, roles: [] }
      result[contributor.jam_id][:roles] << :host if contributor.host?
      result[contributor.jam_id][:roles] << :admin if contributor.admin?
    end

    result.values
  end
end
