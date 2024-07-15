class User < ActiveRecord::Base
  validates :name, :email, presence: true, uniqueness: true
  has_secure_password
  has_one_attached :avatar
end