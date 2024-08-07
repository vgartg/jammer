class User < ActiveRecord::Base
  attr_accessor :remember_token

  validates :name, :email, presence: true, uniqueness: true
  validates :password, :password_confirmation, presence: true, on: :create

  validate :password_length, on: :create
  has_secure_password
  has_one_attached :avatar
  has_many :games, foreign_key: "author_id", dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user, dependent: :destroy

  attr_accessor :current_password

  def password_length
    if password.nil? || password.length < 5
      errors.add(:password, type: :invalid, message: 'must be at least 5 characters long')
    end
  end

  def friend_request(user)
    friendships.create(friend: user)
  end

  def accept_friend_request(user)
    friendship = friendships.find_by(friend: user)
    friendship.update(status: 'accepted') if friendship
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

  def remember_me
    self.remember_token = SecureRandom.urlsafe_base64
    update_column(:remember_token_digest, digest(remember_token))
  end

  def forget_me
    update_column(:remember_token_digest, nil)
    self.remember_token = nil
  end

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def remember_token_authenticated?(remember_token)
    return false unless remember_token_digest.present?
    BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
  end
end
