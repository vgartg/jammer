class JamContributor < ApplicationRecord
  belongs_to :user
  belongs_to :jam

  validates :is_host, inclusion: { in: [true, false] }
  validates :is_admin, inclusion: { in: [true, false] }
  validates :is_judge, inclusion: { in: [true, false] }

  def create
    @contributor = JamContributor.new(jam_id: params[:jam_id])
    @contributor.save
  end

end
