class Session < ActiveRecord::Base
  belongs_to :user

  def self.create_session(user_id, session_id, ip_address)
    Session.create!(
      user_id: user_id,
      session_id: session_id,
      ip_address: ip_address,
      created_at: Time.current
    )
  end
end