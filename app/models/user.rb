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

  attr_accessor :admin_edit, :current_password

  validates :name, :email, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: true, on: :create

  validates :visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
<<<<<<< HEAD
  # validates :jams_visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
=======
  validates :jams_administrating_visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
  validates :jams_participating_visibility, inclusion: { in: [VISIBILITY_ALL, VISIBILITY_FRIENDS, VISIBILITY_NONE] }
>>>>>>> issue_19
  validates :theme, inclusion: { in: [THEME_LIGHT, THEME_DARK] }

  validate :password_length, on: :create
  has_secure_password
  has_one_attached :avatar
  has_one_attached :background_image
  has_many :games, foreign_key: 'author_id', dependent: :destroy
  has_many :jams, foreign_key: 'author_id', dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

<<<<<<< HEAD
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
=======
  has_many :jam_submissions

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
>>>>>>> issue_19
  has_many :inverse_friends, through: :inverse_friendships, source: :user, dependent: :destroy

  has_many :sessions, dependent: :destroy

  has_many :notifications, lambda { |user|
    unscope(where: :user_id).where('actor_id = ? OR recipient_id = ?', user.id, user.id)
  },
           class_name: 'Notification', dependent: :destroy

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

  def create_notification(recipient, actor, action, notifiable)
    existing_notifications = Notification.where(recipient: recipient, actor: actor, action: action,
                                                notifiable: notifiable)

    if existing_notifications.any?
      # Удаляем старые уведомления из БД
      existing_notifications.destroy_all
    end

    Notification.create(recipient: recipient, actor: actor, action: action, notifiable: notifiable)
  end

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

  def notifications
    Notification.where(recipient_id: id)
  end

<<<<<<< HEAD
  def can_see_jams?(other_user)
    case jams_visibility
=======
  def can_see_administrating_jams?(other_user)
    case self.jams_administrating_visibility
>>>>>>> issue_19
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

  def get_all_participating_jams()
    Jam.joins("JOIN jam_submissions ON (jams.id=jam_submissions.jam_id)").where('jam_submissions.user_id = ?', self.id)
  end

  def authenticate_password_reset_token(token)
    digest(password_reset_token) == token
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
end
