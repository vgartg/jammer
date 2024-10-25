require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  def setup
    @user = users(:todd)
    @session_id = SecureRandom.uuid
    @ip_address = "192.168.0.1"
    @browser = "Chrome"
  end

  def test_create_session
    session = Session.create_session(@user.id, @session_id, @ip_address, @browser)
    assert session.persisted?
    assert_equal @user.id, session.user_id
    assert_equal @session_id, session.session_id
    assert_equal @ip_address, session.ip_address
    assert_equal @browser, session.browser
  end

  def test_destroy_session
    session = Session.create_session(@user.id, @session_id, @ip_address, @browser)
    assert_difference 'Session.count', -1 do
      session.destroy
    end
  end
end
