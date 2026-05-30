class AchievementService
  ACHIEVEMENTS = {
    'game_rated_bronze'       => { tier: :bronze,  category: :game_rated,       threshold: 10 },
    'game_rated_silver'       => { tier: :silver,  category: :game_rated,       threshold: 100 },
    'game_rated_gold'         => { tier: :gold,    category: :game_rated,       threshold: 1000 },

    'rated_games_bronze'      => { tier: :bronze,  category: :rated_games,      threshold: 10 },
    'rated_games_silver'      => { tier: :silver,  category: :rated_games,      threshold: 100 },
    'rated_games_gold'        => { tier: :gold,    category: :rated_games,      threshold: 1000 },

    'games_uploaded_bronze'   => { tier: :bronze,  category: :games_uploaded,   threshold: 3 },
    'games_uploaded_silver'   => { tier: :silver,  category: :games_uploaded,   threshold: 10 },
    'games_uploaded_gold'     => { tier: :gold,    category: :games_uploaded,   threshold: 50 },

    'jam_participants_bronze' => { tier: :bronze,  category: :jam_participants, threshold: 25 },
    'jam_participants_silver' => { tier: :silver,  category: :jam_participants, threshold: 50 },
    'jam_participants_gold'   => { tier: :gold,    category: :jam_participants, threshold: 100 },

    'asset_creator_bronze'    => { tier: :bronze,  category: :assets_created,   threshold: 3 },
    'asset_creator_silver'    => { tier: :silver,  category: :assets_created,   threshold: 10 },
    'asset_creator_gold'      => { tier: :gold,    category: :assets_created,   threshold: 30 },

    'social_butterfly'        => { tier: :bronze,  category: :friends_count,    threshold: 10 },

    'team_founder'            => { tier: :bronze,  category: :teams_led,        threshold: 1 },

    'first_blood'             => { tier: :special, category: :special,          threshold: nil },
    'jammer_developer'        => { tier: :special, category: :special,          threshold: nil },
    'jammer_sponsor'          => { tier: :special, category: :special,          threshold: nil },
    'jam_first_time'          => { tier: :special, category: :special,          threshold: nil },
    'jack_of_all_trades'      => { tier: :special, category: :special,          threshold: nil }
  }.freeze

  TIER_ORDER = %i[bronze silver gold special].freeze

  CATEGORY_LABELS = {
    game_rated:       'game_rated',
    rated_games:      'rated_games',
    games_uploaded:   'games_uploaded',
    jam_participants: 'jam_participants',
    assets_created:   'assets_created',
    friends_count:    'friends_count',
    teams_led:        'teams_led'
  }.freeze

  def self.check_and_award(user)
    new(user).check_all
  end

  def self.award_special(user, key)
    return unless ACHIEVEMENTS.key?(key)
    return if user.user_achievements.exists?(achievement_key: key)

    user.user_achievements.create!(achievement_key: key, earned_at: Time.current)
  end

  # Returns progress data for sidebar display, grouped by category.
  # Each entry: { category:, current:, next_key:, next_threshold:, next_tier:, pct:, earned_keys: [] }
  def self.category_progress(user)
    new(user).build_progress
  end

  def initialize(user)
    @user = user
  end

  def check_all
    earned = @user.user_achievements.pluck(:achievement_key).to_set

    ACHIEVEMENTS.each do |key, config|
      next if earned.include?(key)
      next if config[:category] == :special

      award(key) if condition_met?(config)
    end

    check_special_auto
  end

  def build_progress
    earned = @user.user_achievements.pluck(:achievement_key).to_set
    values = current_values

    by_category = ACHIEVEMENTS
      .reject { |_, c| c[:category] == :special }
      .group_by { |_, c| c[:category] }

    by_category.map do |category, pairs|
      sorted = pairs.sort_by { |_, c| c[:threshold] }
      current_val = values[category] || 0

      earned_in_cat = sorted.select { |k, _| earned.include?(k) }.map(&:first)
      next_unearned = sorted.find { |k, _| !earned.include?(k) }

      if next_unearned
        key, config = next_unearned
        pct = [(current_val.to_f / config[:threshold] * 100).round, 100].min
        { category: category, current: current_val, next_key: key,
          next_threshold: config[:threshold], next_tier: config[:tier],
          pct: pct, earned_keys: earned_in_cat }
      else
        max_threshold = sorted.last&.last&.[](:threshold) || 1
        { category: category, current: current_val, next_key: nil,
          next_threshold: max_threshold, next_tier: nil,
          pct: 100, earned_keys: earned_in_cat }
      end
    end
  end

  private

  def check_special_auto
    earned = @user.user_achievements.pluck(:achievement_key).to_set

    unless earned.include?('first_blood')
      if @user.games.where(status: Game::STATUS_ACCEPTED).exists?
        award('first_blood')
      end
    end

    unless earned.include?('jam_first_time')
      if @user.jam_submissions.exists?
        award('jam_first_time')
      end
    end

    unless earned.include?('jack_of_all_trades')
      has_game  = @user.games.where(status: Game::STATUS_ACCEPTED).exists?
      has_jam   = @user.jam_submissions.exists?
      has_asset = @user.assets.exists?
      award('jack_of_all_trades') if has_game && has_jam && has_asset
    end
  end

  def condition_met?(config)
    vals = current_values
    val = vals[config[:category]] || 0
    val >= config[:threshold]
  end

  def current_values
    @current_values ||= {
      game_rated:       total_ratings_received,
      rated_games:      total_ratings_given,
      games_uploaded:   games_uploaded_count,
      jam_participants: total_jam_participants,
      assets_created:   assets_created_count,
      friends_count:    friends_count,
      teams_led:        teams_led_count
    }
  end

  def total_ratings_received
    @total_ratings_received ||= Review.joins(:game).where(games: { author_id: @user.id }).count
  end

  def total_ratings_given
    @total_ratings_given ||= Review.where(user: @user).count
  end

  def games_uploaded_count
    @games_uploaded_count ||= @user.games.where(status: Game::STATUS_ACCEPTED).count
  end

  def assets_created_count
    @assets_created_count ||= @user.assets.count
  end

  def friends_count
    @friends_count ||= begin
      accepted = Friendship.where('(user_id = ? OR friend_id = ?) AND status = ?', @user.id, @user.id, 'accepted').count
      accepted
    end
  end

  def teams_led_count
    @teams_led_count ||= @user.led_teams.count
  end

  def total_jam_participants
    @total_jam_participants ||= begin
      jam_ids = @user.jams.pluck(:id)
      if jam_ids.empty?
        0
      else
        JamSubmission.where(jam_id: jam_ids).select(:user_id).distinct.count
      end
    end
  end

  def award(key)
    ua = @user.user_achievements.create!(achievement_key: key, earned_at: Time.current)
    User.create_notification(@user, @user, 'earned_achievement', ua)
  rescue ActiveRecord::RecordNotUnique
    # already awarded by concurrent call
  end
end
