class Session < ActiveRecord::Base
  belongs_to :user

  def self.create_session(user_id, session_id, ip_address, browser)
    Session.create!(
      user_id: user_id,
      session_id: session_id,
      ip_address: ip_address,
      browser: browser,
      created_at: Time.current
    )
  end
end
