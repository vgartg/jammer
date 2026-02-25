class JamVotesController < ApplicationController
  before_action :authenticate_user
  before_action :set_jam_and_game

  def new
    authorize_vote!
    @criteria = @jam.jam_criteria.order(:position, :id)
    @vote_type = default_vote_type
    @existing = existing_reviews_indexed(@vote_type)
  end

  def create
    authorize_vote!
    criteria = @jam.jam_criteria.order(:position, :id)

    vote_type = params[:vote_type].to_s
    vote_type = default_vote_type if vote_type.blank?

    if vote_type == "jury" && !@jam.can_vote_as_jury?(current_user)
      flash[:failure] = "Недостаточно прав для голосования жюри"
      return redirect_to new_jam_game_vote_path(@jam, @game)
    end

    if vote_type == "audience" && !@jam.can_vote_as_audience?(current_user)
      flash[:failure] = "Недостаточно прав для голосования аудитории"
      return redirect_to new_jam_game_vote_path(@jam, @game)
    end

    Review.transaction do
      criteria.each do |criterion|
        mark_raw = params.dig(:marks, criterion.id.to_s)
        comment_raw = params.dig(:comments, criterion.id.to_s)

        mark = mark_raw.to_f
        mark = 0.0 if mark < 0
        mark = 5.0 if mark > 5

        review = Review.find_or_initialize_by(
          user_id: current_user.id,
          game_id: @game.id,
          jam_id: @jam.id,
          criterion: criterion.title,
          vote_type: Review.vote_types[vote_type]
        )

        review.user_mark = mark
        review.comment = comment_raw.to_s.strip.presence
        review.save!
      end
    end

    flash[:success] = "Оценки сохранены"
    redirect_to game_profile_path(@game, jam_id: @jam.id)
  rescue ActiveRecord::RecordInvalid => e
    flash[:failure] ||= []
    flash[:failure] << e.record.errors.full_messages.join(", ")
    redirect_to new_jam_game_vote_path(@jam, @game)
  end

  private

  def set_jam_and_game
    @jam = Jam.find(params[:jam_id])
    @game = Game.find(params[:game_id])
  end

  def authorize_vote!
    unless @jam.voting_open?
      flash[:failure] = "Голосование сейчас закрыто"
      redirect_to jam_profile_path(@jam) and return
    end

    setting = @jam.rating_setting
    unless setting.jury_enabled || setting.audience_enabled
      flash[:failure] = "Голосование отключено"
      redirect_to jam_profile_path(@jam) and return
    end

    unless @jam.can_vote_as_jury?(current_user) || @jam.can_vote_as_audience?(current_user)
      flash[:failure] = "Недостаточно прав для голосования"
      redirect_to jam_profile_path(@jam) and return
    end
  end

  def default_vote_type
    @jam.can_vote_as_jury?(current_user) ? "jury" : "audience"
  end

  def existing_reviews_indexed(vote_type_str)
    vt = Review.vote_types[vote_type_str]
    Review.where(
      user_id: current_user.id,
      game_id: @game.id,
      jam_id: @jam.id,
      vote_type: vt
    ).index_by(&:criterion)
  end
end