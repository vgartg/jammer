class User < ActiveRecord::Base
  validates :name, :email, presence: true, uniqueness: true
  has_secure_password

  has_many :friendships
  has_many :friends, through: :friendships

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user

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
end