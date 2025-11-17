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
<<<<<<< HEAD
end
=======

  def test_user_creation_without_email
    user = User.new(name: 'Test User', password: 'validpassword', password_confirmation: 'validpassword')
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  def test_user_creation_without_name
    user = User.new(email: 'test@example.com', password: 'validpassword', password_confirmation: 'validpassword')
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  def test_user_creation_with_duplicate_email
    user = User.new(name: 'Test User', email: @user.email, password: 'validpassword', password_confirmation: 'validpassword')
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  def test_password_length_validation
    user = User.new(name: 'Test User', email: 'test@example.com', password: '123', password_confirmation: '123')
    assert_not user.valid?
    assert_includes user.errors[:password], 'must be at least 5 characters long'
  end

  def test_friendship_status_when_not_friends
    friendship = @user.friendship_with(@another_user)
    assert_nil friendship
  end

  def test_user_online_status_after_activity
    @user.update(last_active_at: Time.current - 2.minutes)
    assert_not @user.online?
    @user.update(last_active_at: Time.current)
    assert @user.online?
  end

  def test_destroy_user_with_associated_friendships
    @user.friend_request(@another_user)
    @another_user.accept_friend_request(@user)
    assert_difference '@user.friendships.count', -1 do
      @user.destroy
    end
  end

  def test_user_friendship_with_self
    assert_nil @user.friendship_with(@user)
  end
end
>>>>>>> issue_19
