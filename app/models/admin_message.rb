class AdminMessage < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  validates :title, :body, presence: true
end
