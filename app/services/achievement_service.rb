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

    'jammer_developer'        => { tier: :special, category: :special,          threshold: nil }
  }.freeze

  TIER_ORDER = %i[bronze silver gold special].freeze

  def self.check_and_award(user)
    new(user).check_all
  end

  def self.award_special(user, key)
    return unless ACHIEVEMENTS.key?(key)
    return if user.user_achievements.exists?(achievement_key: key)

    user.user_achievements.create!(achievement_key: key, earned_at: Time.current)
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
  end

  private

  def condition_met?(config)
    case config[:category]
    when :game_rated       then total_ratings_received >= config[:threshold]
    when :rated_games      then total_ratings_given >= config[:threshold]
    when :games_uploaded   then games_uploaded_count >= config[:threshold]
    when :jam_participants then total_jam_participants >= config[:threshold]
    else false
    end
  end

  def total_ratings_received
    Review.joins(:game).where(games: { author_id: @user.id }).count
  end

  def total_ratings_given
    Review.where(user: @user).count
  end

  def games_uploaded_count
    @user.games.where(status: 1).count
  end

  def total_jam_participants
    jam_ids = @user.jams.pluck(:id)
    return 0 if jam_ids.empty?

    JamSubmission.where(jam_id: jam_ids).select(:user_id).distinct.count
  end

  def award(key)
    @user.user_achievements.create!(achievement_key: key, earned_at: Time.current)
  rescue ActiveRecord::RecordNotUnique
    # already awarded by concurrent call
  end
end
