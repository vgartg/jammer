require 'test_helper'

class OnlineStatusTest < ActiveSupport::TestCase
  def setup
    @user = users(:bob)
  end

  def test_online_status
    now = Time.current

    # Пользователь онлайн (последняя активность менее минуты назад)
    @user.update!(last_active_at: now - 30.seconds)
    assert_equal 'Online', online_status(@user)

    @user.update!(last_active_at: now - 55.seconds)
    assert_equal 'Online', online_status(@user)

    @user.update!(last_active_at: now - 0.minutes)
    assert_equal 'Online', online_status(@user)

    # Пользователь был в сети несколько минут назад
    @user.update!(last_active_at: now - 1.minutes)
    assert_equal 'Был в сети 1 минуту назад', online_status(@user)

    @user.update!(last_active_at: now - 3.minutes)
    assert_equal 'Был в сети 3 минуты назад', online_status(@user)

    @user.update!(last_active_at: now - 6.minutes)
    assert_equal 'Был в сети 6 минут назад', online_status(@user)

    @user.update!(last_active_at: now - 11.minutes)
    assert_equal 'Был в сети 11 минут назад', online_status(@user)

    # Пользователь был в сети несколько часов назад
    @user.update!(last_active_at: now - 1.hours)
    assert_equal 'Был в сети 1 час назад', online_status(@user)

    @user.update!(last_active_at: now - 2.hours)
    assert_equal 'Был в сети 2 часа назад', online_status(@user)

    @user.update!(last_active_at: now - 5.hours)
    assert_equal 'Был в сети 5 часов назад', online_status(@user)

    @user.update!(last_active_at: now - 12.hours)
    assert_equal 'Был в сети 12 часов назад', online_status(@user)

    # Пользователь был в сети несколько дней назад
    @user.update!(last_active_at: now - 1.day)
    assert_equal 'Был в сети 1 день назад', online_status(@user)

    @user.update!(last_active_at: now - 9.days)
    assert_equal 'Был в сети 9 дней назад', online_status(@user)

    @user.update!(last_active_at: now - 13.days)
    assert_equal 'Был в сети 13 дней назад', online_status(@user)
  end

  private

  # Метод для получения статуса онлайн пользователя
  def online_status(user)
    now = Time.current.utc
    last_active_at_utc = user.last_active_at.utc
    time_diff = now - last_active_at_utc

    seconds_diff = time_diff.to_i.abs
    minutes_diff = (seconds_diff / 60).to_i.abs
    hours_diff = (minutes_diff / 60).to_i.abs
    days_diff = (hours_diff / 24).to_i.abs

    if days_diff > 0
      "Был в сети #{days_diff} #{day_title(days_diff, %w[дней день дня])} назад"
    elsif hours_diff > 0
      "Был в сети #{hours_diff} #{day_title(hours_diff, %w[часов час часа])} назад"
    elsif minutes_diff > 0
      "Был в сети #{minutes_diff} #{day_title(minutes_diff, %w[минут минуту минуты])} назад"
    else
      'Online'
    end
  end

  # Метод для склонения слов по числу
  def day_title(number, titles)
    if number > 10 && [11, 12, 13, 14].include?(number % 100)
      titles[0]
    else
      last_num = number % 10
      if last_num == 1
        titles[1]
      elsif [2, 3, 4].include?(last_num)
        titles[2]
      else
        titles[0]
      end
    end
  end
end
