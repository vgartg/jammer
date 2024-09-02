require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:todd)
    @another_user = users(:bob)
  end

  def test_password_confirmation_mismatch
    @user.password = 'validpassword'
    @user.password_confirmation = 'mismatch'
    assert_not @user.valid?
    assert_includes @user.errors[:password_confirmation], "doesn't match Password"
  end

  def test_remember_me
    @user.remember_me
    assert_not_nil @user.remember_token
    assert @user.remember_token_authenticated?(@user.remember_token)
  end

  def test_forget_me
    @user.remember_me
    @user.forget_me
    assert_nil @user.remember_token
    assert_not @user.remember_token_authenticated?(@user.remember_token)
  end

  def test_friendship_creation
    assert_difference '@user.friendships.count', 1 do
      @user.friend_request(@another_user)
    end
  end

  def test_accept_friend_request
    @user.friend_request(@another_user)
    @another_user.accept_friend_request(@user)

    assert_equal 'accepted', @user.friendship_with(@another_user).status
  end



  def test_remove_friend
    @user.friend_request(@another_user)
    @another_user.accept_friend_request(@user)
    assert_difference '@user.friendships.count', -1 do
      @user.remove_friend(@another_user)
    end
  end

  def test_online_status
    assert_not @user.online?
    @user.update(last_active_at: Time.current)
    assert @user.online?
  end
  def test_cascade_games_delete
    todd = users(:todd)
    todd.destroy!

    assert_raises ActiveRecord::RecordNotFound do
      Game.find(games(:tes3).id)
    end
  end

end