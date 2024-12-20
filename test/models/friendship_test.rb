require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  def test_friendship
    # Инициализация пользователей
    bob = users(:bob)
    roza = users(:roza)
    tod = users(:tod)

    # Проверка, что у пустых пользователей нет дружеских отношений
    assert_equal 0, bob.friendships.count + bob.inverse_friendships.count
    assert_equal 0, roza.friendships.count + roza.inverse_friendships.count
    assert_equal 0, tod.friendships.count + tod.inverse_friendships.count

    # Создание дружеских отношений
    friendship_b_r = Friendship.create(user_id: bob.id, friend_id: roza.id)
    friendship_b_r.save

    friendship_b_t = Friendship.create(user_id: bob.id, friend_id: tod.id)
    friendship_b_t.save

    friendship_t_r = Friendship.create(user_id: tod.id, friend_id: roza.id)
    friendship_t_r.save

    # Проверка, что у пользователей появились какие-либо отношения (отправленные/входящие заявки в друзья)
    assert_equal 2, bob.friendships.count + bob.inverse_friendships.count
    assert_equal 2, roza.friendships.count + roza.inverse_friendships.count
    assert_equal 2, tod.friendships.count + tod.inverse_friendships.count

    # Обновление статуса отношений
    friendship_b_r.update(status: 'accepted')
    friendship_t_r.update(status: 'accepted')
    friendship_b_t.destroy

    # Проверка на количество друзей
    assert_equal 1, bob.friends.count + bob.inverse_friends.count
    assert_equal 2, roza.friends.count + roza.inverse_friends.count
    assert_equal 1, tod.friends.count + tod.inverse_friends.count

    # Удаление пользователя и проверка, что все его дружеские отношения удалены
    roza_id = roza.id
    roza.destroy!
    assert_equal 0, bob.friendships.count + bob.inverse_friendships.count
    assert_equal 0, Friendship.where(friend_id: roza_id).count + Friendship.where(user_id: roza_id).count
    assert_equal 0, tod.friendships.count + tod.inverse_friendships.count

    # Создание отношений между оставшимися пользователями
    friendship_t_b = Friendship.create(user_id: tod.id, friend_id: bob.id)
    friendship_t_b.save

    # Проверка отображения отправленной заявки(для tod) и входящей заявки(для bob)
    assert_equal 1, bob.inverse_friends.count
    assert_equal 1, tod.friends.count

    # Принятие дружбы и проверка на количество друзей
    friendship_t_b.update(status: 'accepted')
    assert_equal 1, bob.friends.count + bob.inverse_friends.count
    assert_equal 1, tod.friends.count + tod.inverse_friends.count
  end
end
