class User < ActiveRecord::Base
  validates :name, :email, presence: true, uniqueness: true
  validates :password,  :password_confirmation, presence: true

  validate :password_length
  has_secure_password
  def password_length
    if password.nil? || password.length < 5
      errors.add(:password, type: :invalid, message: 'must be at least 5 characters long')
    end
  end
end