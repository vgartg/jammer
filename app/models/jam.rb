class Jam < ActiveRecord::Base
  validates :name, :description, :start_date, :deadline, :end_date, presence: true
  has_one_attached :cover
  has_one_attached :logo

  has_many :jam_submissions, dependent: :destroy
  has_many :hosts, class_name: 'User', dependent: :destroy
  has_many :admins, class_name: 'User', dependent: :destroy
  has_many :juries, class_name: 'User', dependent: :destroy

  belongs_to :author, foreign_key: 'author_id', class_name: 'User', optional: true
  belongs_to :jury, foreign_key: 'jury_id', class_name: 'User', optional: true
  belongs_to :admin, foreign_key: 'admin_id', class_name: 'User', optional: true
  belongs_to :host, foreign_key: 'host_id', class_name: 'User', optional: true

  has_and_belongs_to_many :tags

  validates_length_of :tags, maximum: 10, message: "Можно выбрать не более 10 тегов"

  def host_update
    # user = User.find(user_id)
    # if self.hosts.include?(user)
    #   self.hosts.delete(user)
    # else
    #   self.hosts << user
    # end
    # self.save
  end

end